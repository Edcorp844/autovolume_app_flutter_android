import 'package:flutter/material.dart';
import 'dart:math';

class VerticalVolumeKnob extends StatefulWidget {
  final double volume;
  final ValueChanged<double>? onVolumeChanged;
  final double size;

  const VerticalVolumeKnob({
    super.key,
    required this.volume,
    this.onVolumeChanged,
    this.size = 180.0,
  });

  @override
  VerticalVolumeKnobState createState() => VerticalVolumeKnobState();
}

class VerticalVolumeKnobState extends State<VerticalVolumeKnob>
    with SingleTickerProviderStateMixin {
  late double _currentVolume;
  late double _rotationAngle;
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentVolume = widget.volume;
    _rotationAngle = _volumeToAngle(widget.volume);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _volumeToAngle(double volume) {
    // 0% at bottom (pi), 100% at top (0)
    return (volume * 2 * pi) - pi;
  }

  double _angleToVolume(double angle) {
    // Convert angle back to volume (0-1)
    return ((angle + pi) / (2 * pi)).clamp(0.0, 1.0);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    _controller.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final currentPosition = details.localPosition;
    final previousPosition = details.localPosition - details.delta;

    // Calculate angles in range -pi to pi
    final previousAngle = atan2(
      previousPosition.dx - center.dx,
      center.dy - previousPosition.dy,
    );
    final currentAngle = atan2(
      currentPosition.dx - center.dx,
      center.dy - currentPosition.dy,
    );

    // Calculate angle delta
    var angleDelta = currentAngle - previousAngle;

    // Normalize the angle delta
    if (angleDelta > pi) {
      angleDelta -= 2 * pi;
    } else if (angleDelta < -pi) {
      angleDelta += 2 * pi;
    }

    setState(() {
      _rotationAngle = (_rotationAngle + angleDelta).clamp(-pi, pi);
      _currentVolume = _angleToVolume(_rotationAngle);
    });

    widget.onVolumeChanged?.call(_currentVolume);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    _controller.reverse();
  }

  @override
  void didUpdateWidget(VerticalVolumeKnob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && widget.volume != _currentVolume) {
      setState(() {
        _currentVolume = widget.volume;
        _rotationAngle = _volumeToAngle(widget.volume);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _VerticalKnobPainter(
                rotationAngle: _rotationAngle,
                volume: _currentVolume,
                glowIntensity: _glowAnimation.value,
                isActive: _isDragging,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VerticalKnobPainter extends CustomPainter {
  final double rotationAngle;
  final double volume;
  final double glowIntensity;
  final bool isActive;

  _VerticalKnobPainter({
    required this.rotationAngle,
    required this.volume,
    required this.glowIntensity,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final indicatorLength = radius * 0.65;
    final indicatorWidth = radius * 0.08;
    final trackWidth = radius * 0.15;

    // Draw the background track (vertical semi-circle)
    final trackPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - trackWidth / 2),
      -pi, // Start at bottom (180°)
      pi, // Sweep to top (0°)
      false,
      trackPaint,
    );

    // Draw the active track (from bottom up)
    final activeTrackPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.8),
              Colors.lightBlueAccent.withOpacity(0.8),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - trackWidth / 2),
      -pi, // Start at bottom (180°)
      pi * volume, // Sweep up based on volume
      false,
      activeTrackPaint,
    );

    // Draw the knob center
    final centerPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.grey.withOpacity(0.2), Colors.blueAccent],
            stops: [0.85, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 0.4))
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);

    // Draw the indicator (pointing towards current volume)
    final indicatorPaint =
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 * glowIntensity);

    final indicatorPath =
        Path()
          ..moveTo(center.dx, center.dy - indicatorLength)
          ..lineTo(
            center.dx + indicatorWidth,
            center.dy - indicatorLength + indicatorWidth,
          )
          ..lineTo(
            center.dx - indicatorWidth,
            center.dy - indicatorLength + indicatorWidth,
          )
          ..close();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle / 2); // Negative because we want 0° at top
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(indicatorPath, indicatorPaint);
    canvas.restore();

    // Draw the volume text at center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(volume * 100).toInt()}',
        style: TextStyle(
          color: Colors.blueAccent,
          fontSize: radius * 0.3,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Draw the % symbol
    final percentPainter = TextPainter(
      text: TextSpan(
        text: '%',
        style: TextStyle(
          color: Colors.blueAccent.withOpacity(0.7),
          fontSize: radius * 0.15,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    percentPainter.paint(
      canvas,
      Offset(
        center.dx + textPainter.width / 2 + 2,
        center.dy - percentPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _VerticalKnobPainter oldDelegate) {
    return rotationAngle != oldDelegate.rotationAngle ||
        volume != oldDelegate.volume ||
        glowIntensity != oldDelegate.glowIntensity ||
        isActive != oldDelegate.isActive;
  }
}
