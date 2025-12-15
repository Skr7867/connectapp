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
    final iconSize = screenWidth > 600 ? 24.0 : 20.0;
    final titleSize = screenWidth > 600 ? 14.0 : 13.0;
    final descSize = screenWidth > 600 ? 12.0 : 11.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C2416).withOpacity(0.6),
                  const Color(0xFF3D3121).withOpacity(0.4),
                ]
              : [
                  const Color(0xFFFFFBF0).withOpacity(0.9),
                  const Color(0xFFFFF8E1).withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD4AF37).withOpacity(0.3)
              : const Color(0xFFE8D590).withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFFD4AF37).withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: isDark
                ? const Color(0xFFFFD700).withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ],
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
                        // Title with icon
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'End-to-end encrypted',
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFF8B7355),
                                  fontFamily: 'OpenSans',
                                  letterSpacing: 0.3,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified_rounded,
                              size: titleSize + 2,
                              color: isDark
                                  ? const Color(0xFFFFD700).withOpacity(0.7)
                                  : const Color(0xFF8B7355).withOpacity(0.7),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Description
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
