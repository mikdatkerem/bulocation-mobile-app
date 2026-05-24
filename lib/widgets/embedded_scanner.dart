import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'skeleton.dart';

class EmbeddedScanner extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final bool isLoading;

  const EmbeddedScanner({
    super.key,
    required this.controller,
    required this.onDetect,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 385.0;
    const double height = 100.0;
    const double radius = 10.0;
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border:
                Border.all(color: color.withValues(alpha: 0.25), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: controller,
                  fit: BoxFit.cover,
                  onDetect: onDetect,
                  placeholderBuilder: (_, __) => const _ScannerPlaceholder(),
                  errorBuilder: (_, error, __) => _ScannerError(error: error),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const CustomPaint(
                  painter: _CornerFrame(color: Colors.white70),
                ),
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: Text(
                    isLoading ? 'Kontrol ediliyor...' : 'QR kodunu okutun',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerPlaceholder extends StatelessWidget {
  const _ScannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      baseColor: Color(0xFF1F2937),
      highlightColor: Color(0xFF334155),
      child: ColoredBox(
        color: Color(0xFF0F172A),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SkeletonFill(radius: 10, color: Color(0xFF1F2937)),
        ),
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied => 'Kamera izni gerekli',
      MobileScannerErrorCode.unsupported => 'Kamera desteklenmiyor',
      _ => 'Kamera açılamadı',
    };

    return ColoredBox(
      color: const Color(0xFF111827),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CornerFrame extends CustomPainter {
  final Color color;
  const _CornerFrame({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 16.0;
    const pad = 10.0;

    canvas.drawPath(
      Path()
        ..moveTo(pad, pad + len)
        ..lineTo(pad, pad)
        ..lineTo(pad + len, pad),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - pad - len, pad)
        ..lineTo(size.width - pad, pad)
        ..lineTo(size.width - pad, pad + len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(pad, size.height - pad - len)
        ..lineTo(pad, size.height - pad)
        ..lineTo(pad + len, size.height - pad),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - pad - len, size.height - pad)
        ..lineTo(size.width - pad, size.height - pad)
        ..lineTo(size.width - pad, size.height - pad - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
