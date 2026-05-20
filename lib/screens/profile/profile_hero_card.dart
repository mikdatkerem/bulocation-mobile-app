part of '../profile_screen.dart';

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.viewModel});

  final _ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEEF2FF),
                      Color(0xFFDBE4FF),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  viewModel.initials,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4338CA),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: viewModel.primaryRole,
                background: const Color(0xFFEEF2FF),
                foreground: const Color(0xFF4338CA),
              ),
              _InfoChip(
                label: viewModel.emailVerified
                    ? 'E-posta doğrulandı'
                    : 'E-posta doğrulanmadı',
                background: viewModel.emailVerified
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                foreground: viewModel.emailVerified
                    ? const Color(0xFF15803D)
                    : const Color(0xFFB91C1C),
              ),
              _InfoChip(
                label: viewModel.accountStatusLabel,
                background: viewModel.isActive
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFFF8FAFC),
                foreground: viewModel.isActive
                    ? const Color(0xFF0369A1)
                    : const Color(0xFF64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
