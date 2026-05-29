import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bill.dart';

class PDFService {
  static String numberToWords(double number) {
    final intAmount = number.toInt();
    if (intAmount == 0) return "Zero Rupees Only";
    
    final units = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"];
    final tens = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"];
    
    String convertLessThanOneThousand(int n) {
      if (n < 20) return units[n];
      if (n < 100) return "${tens[n ~/ 10]}${n % 10 != 0 ? " " + units[n % 10] : ""}";
      return "${units[n ~/ 100]} Hundred${n % 100 != 0 ? " and " + convertLessThanOneThousand(n % 100) : ""}";
    }
    
    int temp = intAmount;
    String result = "";
    if (temp >= 1000) {
      result += "${convertLessThanOneThousand(temp ~/ 1000)} Thousand ";
      temp %= 1000;
    }
    if (temp > 0) {
      result += convertLessThanOneThousand(temp);
    }
    return "${result.trim()} Rupees Only";
  }

  static Future<Uint8List> generateInvoicePDF(BillModel bill) async {
    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    try {
      logoImage = await imageFromAssetBundle('assets/logo.png');
    } catch (e) {
      // Fallback silently if asset is not loaded
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.0),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // TAX INVOICE Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
                    ),
                  ),
                  child: pw.Text(
                    'TAX INVOICE',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                
                // Row 1: Supplier & Invoice Details (using Table to ensure equal heights and proper borders)
                pw.Table(
                  border: const pw.TableBorder(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(),
                    1: const pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        // Supplier details (Left)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              right: pw.BorderSide(color: PdfColors.black, width: 1.0),
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.center,
                                children: [
                                  if (logoImage != null) ...[
                                    pw.Image(logoImage, width: 24, height: 24),
                                    pw.SizedBox(width: 6),
                                  ],
                                  pw.Text(
                                    'CLOUD DENTAL EXPRESS',
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text('Plot No. 42, Dental Tech Park, Sector 3,', style: const pw.TextStyle(fontSize: 8)),
                              pw.Text('Mumbai - 400001, Maharashtra, India', style: const pw.TextStyle(fontSize: 8)),
                              pw.Text('GSTIN/UIN: 27AAAAA1111A1Z1', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                              pw.Text('State Name: Maharashtra, Code: 27', style: const pw.TextStyle(fontSize: 8)),
                              pw.Text('Contact: support@clouddentallab.com', style: const pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        
                        // Invoice details (Right)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Invoice No.:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                                  pw.Text(bill.id, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                                ],
                              ),
                              pw.SizedBox(height: 3),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Dated:', style: const pw.TextStyle(fontSize: 8)),
                                  pw.Text(bill.dateCreated.toString().split(' ')[0], style: const pw.TextStyle(fontSize: 8)),
                                ],
                              ),
                              pw.SizedBox(height: 3),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Buyer\'s Order No.:', style: const pw.TextStyle(fontSize: 8)),
                                  pw.Text(bill.orderId, style: const pw.TextStyle(fontSize: 8)),
                                ],
                              ),
                              pw.SizedBox(height: 3),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Mode/Terms of Payment:', style: const pw.TextStyle(fontSize: 8)),
                                  pw.Text(bill.isPaid ? 'PAID' : 'NET 15 DAYS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: bill.isPaid ? PdfColors.green800 : PdfColors.amber900)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Row 2: Buyer & Dispatch details (using Table)
                pw.Table(
                  border: const pw.TableBorder(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(),
                    1: const pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        // Buyer details (Left)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              right: pw.BorderSide(color: PdfColors.black, width: 1.0),
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Buyer (Bill to):', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'Dr. Clinician Destination',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text('Patient Name: ${bill.patientName}', style: const pw.TextStyle(fontSize: 8)),
                              pw.Text('Order Case Ref: ${bill.orderId}', style: const pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        
                        // Dispatch details (Right)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Dispatched through: Lab Express Courier', style: const pw.TextStyle(fontSize: 8)),
                              pw.SizedBox(height: 3),
                              pw.Text('Dispatch Doc No: CDE-${bill.id}', style: const pw.TextStyle(fontSize: 8)),
                              pw.SizedBox(height: 3),
                              pw.Text('Destination: Clinic Coordinates Pinned', style: const pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Table of charges (Tally format grid)
                pw.Expanded(
                  child: pw.Container(
                    child: pw.Table(
                      border: const pw.TableBorder(
                        verticalInside: pw.BorderSide(color: PdfColors.black, width: 0.5),
                        bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
                      ),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(30),
                        1: const pw.FlexColumnWidth(),
                        2: const pw.FixedColumnWidth(50),
                        3: const pw.FixedColumnWidth(40),
                        4: const pw.FixedColumnWidth(70),
                        5: const pw.FixedColumnWidth(35),
                        6: const pw.FixedColumnWidth(80),
                      },
                      children: [
                        // Table Header
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
                            ),
                          ),
                          children: [
                            _tallyHeader('Sl No.', align: pw.TextAlign.center),
                            _tallyHeader('Description of Goods & Services', align: pw.TextAlign.left),
                            _tallyHeader('HSN/SAC', align: pw.TextAlign.center),
                            _tallyHeader('Qty', align: pw.TextAlign.center),
                            _tallyHeader('Rate', align: pw.TextAlign.right),
                            _tallyHeader('per', align: pw.TextAlign.center),
                            _tallyHeader('Amount (INR)', align: pw.TextAlign.right),
                          ],
                        ),
                        // Service Item Row
                        pw.TableRow(
                          children: [
                            _tallyCell('1', align: pw.TextAlign.center),
                            _tallyCell(
                              '${bill.productName}\n[Patient: ${bill.patientName}, Case: ${bill.orderId}]',
                              align: pw.TextAlign.left,
                              bold: true,
                            ),
                            _tallyCell('998311', align: pw.TextAlign.center),
                            _tallyCell('1 Unit', align: pw.TextAlign.center),
                            _tallyCell('₹${bill.price.toStringAsFixed(2)}', align: pw.TextAlign.right),
                            _tallyCell('Unit', align: pw.TextAlign.center),
                            _tallyCell('₹${bill.price.toStringAsFixed(2)}', align: pw.TextAlign.right),
                          ],
                        ),
                        // Empty Spacer row to mimic Tally invoice layouts
                        pw.TableRow(
                          children: List.generate(7, (i) => _tallyCell('', minHeight: 250)),
                        ),
                        // Total Row
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              top: pw.BorderSide(color: PdfColors.black, width: 1.0),
                            ),
                          ),
                          children: [
                            _tallyCell('', align: pw.TextAlign.center),
                            _tallyCell('Total', align: pw.TextAlign.right, bold: true),
                            _tallyCell('', align: pw.TextAlign.center),
                            _tallyCell('1 Unit', align: pw.TextAlign.center, bold: true),
                            _tallyCell('', align: pw.TextAlign.right),
                            _tallyCell('', align: pw.TextAlign.center),
                            _tallyCell('₹${bill.price.toStringAsFixed(2)}', align: pw.TextAlign.right, bold: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Amount in Words & Tax Summary
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Amount Chargeable (in words):',
                        style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        numberToWords(bill.price),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                      ),
                    ],
                  ),
                ),

                // Declaration & Signatures (using Table)
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(),
                    1: const pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        // Declaration (Left)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              right: pw.BorderSide(color: PdfColors.black, width: 1.0),
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Declaration:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'We declare that this invoice shows the actual price of the goods described and that all particulars are true and correct.',
                                style: const pw.TextStyle(fontSize: 7),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text('Terms & Conditions:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                              pw.Text('1. Goods once sold will not be taken back.', style: const pw.TextStyle(fontSize: 6)),
                              pw.Text('2. Payment is due within 15 days of invoice date.', style: const pw.TextStyle(fontSize: 6)),
                            ],
                          ),
                        ),
                        
                        // Signature box (Right)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'for CLOUD DENTAL EXPRESS',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                              ),
                              pw.SizedBox(height: 35),
                              pw.Text(
                                'Authorized Signatory',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tallyHeader(String text, {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 7.5,
        ),
      ),
    );
  }

  static pw.Widget _tallyCell(String text, {pw.TextAlign align = pw.TextAlign.left, bool bold = false, double minHeight = 0}) {
    return pw.Container(
      constraints: pw.BoxConstraints(minHeight: minHeight),
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 8,
        ),
      ),
    );
  }

  // Print/Download PDF
  static Future<void> printInvoice(BillModel bill) async {
    final pdfBytes = await generateInvoicePDF(bill);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice-${bill.id}',
    );
  }

  // Share via WhatsApp/Share Dialog
  static Future<void> shareInvoice(BillModel bill) async {
    final pdfBytes = await generateInvoicePDF(bill);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Invoice-${bill.id}.pdf');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Here is the Tally-style Invoice ${bill.id} for the dental case of patient ${bill.patientName}. Generated by Cloud Dental Express.',
    );
  }
}
