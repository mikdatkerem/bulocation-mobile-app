part of '../floor_plan_widget.dart';

class _MapAssetSurface extends StatelessWidget {
  const _MapAssetSurface({required this.url, this.contentType});

  final String url;
  final String? contentType;

  @override
  Widget build(BuildContext context) {
    final headers = ApiClient.buildHeaders(includeJsonContentType: false);
    final resolvedContentType = contentType?.toLowerCase() ?? 'image/svg+xml';

    if (resolvedContentType.contains('svg') ||
        url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        fit: BoxFit.contain,
        headers: headers,
        placeholderBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.contain,
      headers: headers,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (_, __, ___) => const Center(
        child:
            Icon(Icons.image_not_supported_outlined, color: Color(0xFF7C869C)),
      ),
    );
  }
}
