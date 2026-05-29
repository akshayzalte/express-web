class BillModel {
  final String id;
  final String orderId;
  final String patientName;
  final String productName;
  final double price;
  final DateTime dateCreated;
  final bool isPaid;
  final String? pdfPath;

  BillModel({
    required this.id,
    required this.orderId,
    required this.patientName,
    required this.productName,
    required this.price,
    required this.dateCreated,
    required this.isPaid,
    this.pdfPath,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      patientName: json['patientName'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      isPaid: json['isPaid'] as bool,
      pdfPath: json['pdfPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'patientName': patientName,
      'productName': productName,
      'price': price,
      'dateCreated': dateCreated.toIso8601String(),
      'isPaid': isPaid,
      'pdfPath': pdfPath,
    };
  }

  BillModel copyWith({
    bool? isPaid,
    String? pdfPath,
  }) {
    return BillModel(
      id: id,
      orderId: orderId,
      patientName: patientName,
      productName: productName,
      price: price,
      dateCreated: dateCreated,
      isPaid: isPaid ?? this.isPaid,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }
}
