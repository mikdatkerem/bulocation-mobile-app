part of '../profile_screen.dart';

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool destructive;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final accent =
        destructive ? const Color(0xFFE04F4F) : const Color(0xFF2155D6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: () async => onTap?.call(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                destructive ? const Color(0xFFFFEFEF) : const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accent),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                destructive ? const Color(0xFFD73F3F) : const Color(0xFF1B2438),
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color:
              destructive ? const Color(0xFFE7A2A2) : const Color(0xFFA0AABE),
        ),
      ),
    );
  }
}
