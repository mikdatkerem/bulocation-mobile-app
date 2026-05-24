import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/api_client.dart';
import '../main.dart';

class MapAssetPreview extends StatelessWidget {
  const MapAssetPreview({
    super.key,
    required this.assetPath,
    required this.assetContentType,
  });

  final String assetPath;
  final String assetContentType;

  @override
  Widget build(BuildContext context) {
    final url = _resolveUrl(assetPath);
    final headers = ApiClient.buildHeaders(includeJsonContentType: false);
    final contentType = assetContentType.toLowerCase();
    final isSvg =
        contentType.contains('svg') || url.toLowerCase().endsWith('.svg');

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: const Color(0xFFF8FAFC),
        child: isSvg
            ? SvgPicture.network(
                url,
                headers: headers,
                fit: BoxFit.cover,
                placeholderBuilder: (_) => const _PreviewLoading(),
              )
            : Image.network(
                url,
                headers: headers,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const _PreviewLoading(),
                errorBuilder: (_, __, ___) => const _PreviewFallback(),
              ),
      ),
    );
  }

  String _resolveUrl(String path) {
    if (path.isEmpty) {
      return AppConfig.mapSvgUrl;
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return '${AppConfig.baseHost}$path';
  }
}

class _PreviewLoading extends StatelessWidget {
  const _PreviewLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.map_outlined,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
