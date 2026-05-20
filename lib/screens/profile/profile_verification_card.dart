part of '../profile_screen.dart';

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            color: Color(0xFFA16207),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-posta doğrulaması bekleniyor',
                  style: TextStyle(
                    color: Color(0xFF713F12),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Şifre sıfırlama ve güvenlik işlemleri için hesabınızı doğrulayın.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async => onTap(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA16207),
            ),
            child: const Text(
              'Doğrula',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
