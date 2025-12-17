import 'package:flutter/material.dart';

class EncryptionNotice extends StatelessWidget {
  const EncryptionNotice({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme for dynamic coloring
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding and sizing
    final horizontalMargin = screenWidth > 600 ? 32.0 : 20.0;
    final iconSize = screenWidth > 600 ? 20.0 : 18.0;
    final descSize = screenWidth > 600 ? 10.0 : 10.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD4AF37).withOpacity(0.1)
              : const Color(0xFFE8D590).withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Subtle background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _DotPatternPainter(
                  color: isDark
                      ? Colors.white.withOpacity(0.03)
                      : const Color(0xFFD4AF37).withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(screenWidth > 600 ? 16.0 : 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced lock icon with animation-ready container
                  Container(
                    padding: EdgeInsets.all(screenWidth > 600 ? 10.0 : 8.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFFFFD700).withOpacity(0.25),
                                const Color(0xFFD4AF37).withOpacity(0.15),
                              ]
                            : [
                                const Color(0xFFFFD700).withOpacity(0.3),
                                const Color(0xFFFFC107).withOpacity(0.2),
                              ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: iconSize,
                      color: isDark
                          ? const Color(0xFFFFD700)
                          : const Color(0xFFD4AF37),
                    ),
                  ),

                  SizedBox(width: screenWidth > 600 ? 16.0 : 12.0),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Messages and calls are end-to-end encrypted. Only people in this chat can read, listen to, or share them.',
                          style: TextStyle(
                            fontSize: descSize,
                            color: isDark
                                ? const Color(0xFFE8D590).withOpacity(0.85)
                                : const Color(0xFF8B7355).withOpacity(0.9),
                            height: 1.5,
                            fontFamily: 'OpenSans',
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for subtle dot pattern background
class _DotPatternPainter extends CustomPainter {
  final Color color;

  _DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
