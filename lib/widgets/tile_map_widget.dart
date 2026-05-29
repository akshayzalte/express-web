import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TileMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final double height;
  final double width;

  const TileMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15.0,
    this.height = 130.0,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    // Zoom as integer for tiling
    final int z = zoom.round();
    final n = pow(2, z);

    // Calculate fractional x and y tile coordinates
    final double x = ((longitude + 180.0) / 360.0) * n;
    final double latRad = latitude * pi / 180.0;
    // To prevent infinity on tan/sec, we clamp latitude
    final double clampedLatRad = latRad.clamp(-85.0511 * pi / 180.0, 85.0511 * pi / 180.0);
    final double y = (1.0 - (log(tan(clampedLatRad) + 1.0 / cos(clampedLatRad)) / pi)) / 2.0 * n;

    // Center tile indices
    final int cx = x.floor();
    final int cy = y.floor();

    // Render a 3x3 tile grid (each tile is 256x256 pixels)
    // Offset inside the grid:
    // cx - 1, cx, cx + 1
    // cy - 1, cy, cy + 1
    // Top-left tile starts at cx - 1, cy - 1.
    // The relative location of target coordinates in pixels inside this 3x3 grid (768x768 pixels):
    // px = (x - (cx - 1)) * 256
    // py = (y - (cy - 1)) * 256
    final double px = (x - (cx - 1)) * 256;
    final double py = (y - (cy - 1)) * 256;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth == double.infinity ? 300.0 : constraints.maxWidth;
        final double h = height;

        // Position the 768x768 tile grid so the target coordinate (px, py) is at the center of the viewport (w/2, h/2)
        final double gridLeft = w / 2 - px;
        final double gridTop = h / 2 - py;

        return SizedBox(
          width: w,
          height: h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 3x3 grid of tiles
                Positioned(
                  left: gridLeft,
                  top: gridTop,
                  width: 768,
                  height: 768,
                  child: Container(
                    color: isDark ? const Color(0xFF0F1E31) : const Color(0xFFEAF0F6),
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(256),
                        1: FixedColumnWidth(256),
                        2: FixedColumnWidth(256),
                      },
                      children: List.generate(3, (rowIdx) {
                        final int currentY = cy - 1 + rowIdx;
                        return TableRow(
                          children: List.generate(3, (colIdx) {
                            final int currentX = cx - 1 + colIdx;
                            // CartoDB Voyager tiles (Cloudflare CDN)
                            // We can use a subdomain selector a, b, or c.
                            final String sub = ['a', 'b', 'c'][(currentX + currentY).abs() % 3];
                            final String tileUrl = isDark 
                              ? 'https://$sub.basemaps.cartocdn.com/dark_all/$z/$currentX/$currentY.png'
                              : 'https://$sub.basemaps.cartocdn.com/rastertiles/voyager/$z/$currentX/$currentY.png';
                            
                            return SizedBox(
                              width: 256,
                              height: 256,
                              child: CachedNetworkImage(
                                imageUrl: tileUrl,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(milliseconds: 150),
                                placeholder: (context, url) => Container(
                                  color: isDark ? const Color(0xFF0F1E31) : const Color(0xFFDCE6F1),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: isDark ? const Color(0xFF1B2A3E) : const Color(0xFFCFD8DC),
                                  child: const Icon(Icons.map_outlined, color: Colors.grey, size: 24),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),

                // Center Pin Drop Marker Overlay
                Positioned(
                  left: w / 2 - 20,
                  top: h / 2 - 40,
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.redAccent,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),

                // Attribution logo/text in bottom-right corner
                Positioned(
                  bottom: 4,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '© OpenStreetMap, CARTO',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
