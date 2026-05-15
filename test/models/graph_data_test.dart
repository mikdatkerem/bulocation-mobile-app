import 'package:flutter_test/flutter_test.dart';
import 'package:qr_location_app/models/graph_data.dart';

void main() {
  group('graph_data helpers', () {
    test('normalizeSearchText normalizes Turkish characters', () {
      expect(normalizeSearchText('Çıkış Üst Kat'), 'cikis ust kat');
    });

    test('compareNodeLabelsNatural sorts labels by numeric chunks', () {
      final labels = ['P19', 'P2', 'P21', 'P10']..sort(compareNodeLabelsNatural);

      expect(labels, ['P2', 'P10', 'P19', 'P21']);
    });

    test('MapNode resolves normalized coordinates when available', () {
      const node = MapNode(
        id: 'P1',
        label: 'P1',
        x: 240,
        y: 120,
        type: NodeType.park,
        normalizedX: 0.5,
        normalizedY: 0.25,
      );

      expect(node.resolveX(1000), 500);
      expect(node.resolveY(800), 200);
    });
  });
}
