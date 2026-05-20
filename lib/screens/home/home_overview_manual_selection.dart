part of '../home_overview_screen.dart';

class _ManualSelectionPanel extends StatelessWidget {
  const _ManualSelectionPanel({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MANUEL SEÇİM',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'QR yoksa kurum seçerek devam edin.',
            style: TextStyle(
              color: _ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Önce kurum seçin. Ardından yerleşke, bina ve kat adımlarıyla ilgili haritayı açın.',
            style: TextStyle(
              color: _soft,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _surfaceMuted,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _line),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: _accent, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kurum, bina veya kat seç',
                      style: TextStyle(
                        color: _soft,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: _ink),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
