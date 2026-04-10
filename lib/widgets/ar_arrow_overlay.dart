import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/detected_text_target.dart';
import '../services/ar_navigation_service.dart';

class ARArrowOverlay extends StatefulWidget {
  final DetectedTextTarget target;
  final ARNavigationService arService;
  final AnimationController arrowAnimation;
  final double? smoothAngle;

  const ARArrowOverlay({
    super.key,
    required this.target,
    required this.arService,
    required this.arrowAnimation,
    this.smoothAngle,
  });

  @override
  State<ARArrowOverlay> createState() => _ARArrowOverlayState();
}

class _ARArrowOverlayState extends State<ARArrowOverlay> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const imageWidth = 720.0;
    const imageHeight = 1280.0;

    final targetScreenX = (widget.target.centerX / imageWidth) * size.width;
    final targetScreenY = (widget.target.centerY / imageHeight) * size.height;

    final dx = targetScreenX - (size.width / 2);
    final dy = targetScreenY - (size.height / 2);
    final distance = math.sqrt(dx * dx + dy * dy);
    final isOnTarget = distance < 60;

    // Use smoothAngle if provided, otherwise compute instantaneous angle
    final angle = widget.smoothAngle ?? math.atan2(dx, -dy);

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ARArrowPainter(
            targetX: targetScreenX,
            targetY: targetScreenY,
            angle: angle,
            distance: distance,
            isOnTarget: isOnTarget,
            animValue: widget.arrowAnimation.value,
            isMatch: widget.target.isMatch,
          ),
          child: isOnTarget
              ? _buildOnTargetIndicator(size, targetScreenX, targetScreenY)
              : null,
        ),
      ),
    );
  }

  Widget _buildOnTargetIndicator(Size size, double targetX, double targetY) {
    return AnimatedBuilder(
      animation: widget.arrowAnimation,
      builder: (_, __) {
        final scale = 1.0 + widget.arrowAnimation.value * 0.15;
        return Stack(
          children: [
            Positioned(
              left: targetX - 60,
              top: targetY - 60,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1D9E75), // Maak teal
                      width: 2,
                    ),
                    color: const Color(0xFF1D9E75).withValues(alpha: 0.12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF1D9E75),
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ARArrowPainter extends CustomPainter {
  final double targetX;
  final double targetY;
  final double angle;
  final double distance;
  final bool isOnTarget;
  final double animValue;
  final bool isMatch;

  ARArrowPainter({
    required this.targetX,
    required this.targetY,
    required this.angle,
    required this.distance,
    required this.isOnTarget,
    required this.animValue,
    required this.isMatch,
  });

  // Maak design colors
  static const Color arrowColor = Color(0xFF60A5FA);   // light blue
  static const Color matchColor = Color(0xFF1D9E75);   // Maak teal
  static const Color primaryColor = Color(0xFF1E40AF); // Maak deep blue

  @override
  void paint(Canvas canvas, Size size) {
    final color = isMatch ? matchColor : arrowColor;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    if (isOnTarget) {
      _drawOnTargetEffect(canvas, color);
      return;
    }

    _drawDashedLine(canvas, Offset(centerX, centerY),
        Offset(targetX, targetY), color);
    _drawMainArrow(canvas, size, color);
    _drawTargetPoint(canvas, color);
    _drawDistanceInfo(canvas, size, color);
  }

  void _drawMainArrow(Canvas canvas, Size size, Color color) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    final offset = animValue * 15;

    // Segmented Chevron Design
    for (int i = 0; i < 3; i++) {
      final stepOpacity = (1.0 - (i * 0.3)) * (1.0 - animValue * 0.5);
      final stepOffset = (i * 20.0) - offset;
      
      if (stepOffset < 0) continue;

      final p = Paint()
        ..color = color.withValues(alpha: stepOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 - (i * 0.8)
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(-15 + (i * 2), 40 + stepOffset);
      path.lineTo(0, 25 + stepOffset);
      path.lineTo(15 - (i * 2), 40 + stepOffset);
      
      canvas.drawPath(path, p);
      
      // Glow for the first chevron
      if (i == 0) {
        canvas.drawPath(path, Paint()
          ..color = color.withValues(alpha: 0.3 * stepOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      }
    }

    // Core Indicator
    canvas.drawCircle(
      Offset.zero,
      6,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset.zero,
      6,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
    _drawDirectionLabel(canvas, size, color);
  }

  void _drawTargetPoint(Canvas canvas, Color color) {
    // Holographic Target Marker
    final haloPaint = Paint()
      ..color = color.withValues(alpha: 0.1 + animValue * 0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(targetX, targetY), 25 + animValue * 10, haloPaint);

    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Rotating-like brackets around target
    canvas.save();
    canvas.translate(targetX, targetY);
    canvas.rotate(animValue * math.pi);
    
    const bracketLen = 8.0;
    const dist = 18.0;
    
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 2);
      canvas.drawLine(const Offset(dist, -bracketLen), const Offset(dist, bracketLen), ringPaint);
      canvas.restore();
    }
    canvas.restore();

    canvas.drawCircle(Offset(targetX, targetY), 4, Paint()..color = color);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 50) return; // Don't draw if too close

    const dashLen = 4.0;
    const gapLen = 8.0;
    final totalLen = dashLen + gapLen;
    final steps = (len / totalLen).floor();

    for (int i = 0; i < steps; i++) {
      final t1 = i * totalLen / len;
      final t2 = (i * totalLen + dashLen) / len;
      if (t2 > 1) break;
      canvas.drawLine(
        Offset(start.dx + dx * t1, start.dy + dy * t1),
        Offset(start.dx + dx * t2, start.dy + dy * t2),
        paint,
      );
    }
  }

  void _drawDistanceInfo(Canvas canvas, Size size, Color color) {
    final normalizedDist = (distance / (size.width / 2) * 100).clamp(0, 100);
    final distText = 'PROXIMITÉ : ${normalizedDist.toStringAsFixed(0)}%';

    final tp = TextPainter(
      text: TextSpan(
        text: distText,
        style: TextStyle(
          color: color.withValues(alpha: 0.8),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height / 2 + 50));
  }

  void _drawDirectionLabel(Canvas canvas, Size size, Color color) {
    final deg = (angle * 180 / math.pi + 360) % 360;
    String label;
    if (deg < 22.5 || deg >= 337.5) label = 'DIRECTION : NORD';
    else if (deg < 67.5) label = 'DIRECTION : NE';
    else if (deg < 112.5) label = 'DIRECTION : EST';
    else if (deg < 157.5) label = 'DIRECTION : SE';
    else if (deg < 202.5) label = 'DIRECTION : SUD';
    else if (deg < 247.5) label = 'DIRECTION : SO';
    else if (deg < 292.5) label = 'DIRECTION : OUEST';
    else label = 'DIRECTION : NO';

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color.withValues(alpha: 0.6),
          fontSize: 8,
          fontFamily: 'monospace',
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas,
        Offset(size.width / 2 - tp.width / 2, size.height / 2 + 70));
  }

  void _drawOnTargetEffect(Canvas canvas, Color color) {
    final cx = targetX;
    final cy = targetY;
    
    // Multi-layered pulsating rings
    for (int i = 1; i <= 4; i++) {
      final ringAnim = (animValue + (i * 0.2)) % 1.0;
      canvas.drawCircle(
        Offset(cx, cy),
        15.0 + ringAnim * 40,
        Paint()
          ..color = color.withValues(alpha: (1.0 - ringAnim) * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 + (1.0 - ringAnim) * 2,
      );
    }
    
    // Core glow
    canvas.drawCircle(
      Offset(cx, cy),
      20,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }


  @override
  bool shouldRepaint(ARArrowPainter old) =>
      old.animValue != animValue ||
      old.targetX != targetX ||
      old.targetY != targetY;
}
