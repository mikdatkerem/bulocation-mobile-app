part of '../home_overview_screen.dart';

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrStage extends StatelessWidget {
  const _QrStage({
    required this.pulse,
    required this.onTap,
  });

  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scanOffset = 22 + (pulse.value * 72);

    return Semantics(
      button: true,
      label: 'QR okut',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 194,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 184,
                height: 184,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(32),
                  border:
                      Border.all(color: const Color(0x336366F1), width: 1.4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x140F172A),
                      blurRadius: 24,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: _QrFrame(),
                      ),
                    ),
                    Positioned(
                      left: 26,
                      right: 26,
                      top: scanOffset,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0x0022D3EE),
                              Color(0xAA22D3EE),
                              Color(0xAA6366F1),
                              Color(0x0022D3EE),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrFrame extends StatelessWidget {
  const _QrFrame();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFF),
                  Color(0xFFF2F5FF),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _QrCornerPainter(),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                size: 62,
                color: Color(0xFF4F46E5),
              ),
              SizedBox(height: 10),
              Text(
                'QR okut',
                style: TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrCornerPainter extends CustomPainter {
  const _QrCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF6366F1);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const corner = 18.0;
    const inset = 12.0;

    void drawCorner(Offset start, Offset horizontalEnd, Offset verticalEnd) {
      canvas.drawLine(start, horizontalEnd, paint);
      canvas.drawLine(start, verticalEnd, paint);
    }

    drawCorner(
      const Offset(inset, inset),
      const Offset(inset + corner, inset),
      const Offset(inset, inset + corner),
    );
    drawCorner(
      Offset(size.width - inset, inset),
      Offset(size.width - inset - corner, inset),
      Offset(size.width - inset, inset + corner),
    );
    drawCorner(
      Offset(inset, size.height - inset),
      Offset(inset + corner, size.height - inset),
      Offset(inset, size.height - inset - corner),
    );
    drawCorner(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset - corner, size.height - inset),
      Offset(size.width - inset, size.height - inset - corner),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
