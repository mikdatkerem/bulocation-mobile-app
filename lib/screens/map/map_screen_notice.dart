enum MapScreenNoticeLevel { info, warning }

class MapScreenNotice {
  const MapScreenNotice({
    required this.id,
    required this.title,
    this.message,
    this.level = MapScreenNoticeLevel.info,
  });

  final int id;
  final String title;
  final String? message;
  final MapScreenNoticeLevel level;
}
