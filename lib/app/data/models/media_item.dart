/// Content is mixed media, so audio and video share one entity and the
/// player branches on [type] rather than the app carrying two parallel models.
enum MediaType { audio, video, article }

class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.durationSeconds,
    this.subtitle = '',
    this.tag = 'Meditation',
    this.description = '',
    this.coverUrl = '',
    this.coverAsset = '',
    this.remoteUrl = '',
    this.localPath,
    this.rating = 0,
    this.categoryId = '',
    this.practitionerName = '',
    this.isFree = true,
  });

  final String id;
  final String title;
  final String subtitle;

  /// The white pill over the cover art — "Meditation", "Voice over",
  /// "Sound effect". Per item, not derived from the media type.
  final String tag;
  final String description;
  final MediaType type;
  final int durationSeconds;
  final String coverUrl;

  /// Bundled cover art, exported from Figma. Distinct from [coverUrl], which
  /// is the remote one the API will serve — this is what ships in the app and
  /// is what the mock uses while there is no backend.
  final String coverAsset;

  /// Streamed source. Expected to be a short-lived signed URL once the
  /// Django backend is in place, so it must not be persisted long-term.
  final String remoteUrl;

  /// Set once the file has been downloaded. A non-null value is the single
  /// signal that an item is available offline — there is no separate
  /// "downloads" state to keep in sync.
  final String? localPath;

  /// Average score out of 5, shown on a Discovery card's dark pill. Zero
  /// means unrated, which the card treats as "hide the pill" rather than 0.0.
  final double rating;

  final String categoryId;
  final String practitionerName;
  final bool isFree;

  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;

  Duration get duration => Duration(seconds: durationSeconds);

  MediaItem copyWith({String? localPath}) => MediaItem(
        id: id,
        title: title,
        subtitle: subtitle,
        tag: tag,
        description: description,
        rating: rating,
        type: type,
        durationSeconds: durationSeconds,
        coverUrl: coverUrl,
        coverAsset: coverAsset,
        remoteUrl: remoteUrl,
        localPath: localPath ?? this.localPath,
        categoryId: categoryId,
        practitionerName: practitionerName,
        isFree: isFree,
      );

  /// DRF returns snake_case; keys here match that contract so swapping the
  /// mock source for the real API needs no model changes.
  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        id: '${json['id']}',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        tag: json['tag'] as String? ?? 'Meditation',
        description: json['description'] as String? ?? '',
        type: MediaType.values.firstWhere(
          (t) => t.name == json['media_type'],
          orElse: () => MediaType.audio,
        ),
        durationSeconds: json['duration_seconds'] as int? ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        coverUrl: json['cover_url'] as String? ?? '',
        remoteUrl: json['media_url'] as String? ?? '',
        categoryId: '${json['category'] ?? ''}',
        practitionerName: json['practitioner_name'] as String? ?? '',
        isFree: json['is_free'] as bool? ?? true,
      );
}

class Category {
  const Category({
    required this.id,
    required this.name,
    this.description = '',
    this.coverUrl = '',
  });

  final String id;
  final String name;
  final String description;
  final String coverUrl;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: '${json['id']}',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        coverUrl: json['cover_url'] as String? ?? '',
      );
}
