part of '../home_overview_screen.dart';

class _QuickScannerSheet extends StatelessWidget {
  const _QuickScannerSheet({
    required this.controller,
    required this.onDetect,
  });

  final MobileScannerController controller;
  final Future<void> Function(String referenceId) onDetect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'QR okut',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'QR hangi kat veya binaya aitse ilgili harita otomatik açılır.',
                style: TextStyle(
                  height: 1.55,
                  color: _soft,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x306366F1)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x140F172A),
                      blurRadius: 20,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 320,
                    child: MobileScanner(
                      controller: controller,
                      onDetect: (capture) async {
                        final value =
                            capture.barcodes.firstOrNull?.rawValue?.trim();
                        if (value == null || value.isEmpty) {
                          return;
                        }
                        await onDetect(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
