/// Collectible / progression models: inventory, evidence, journal, objectives,
/// achievements and gallery unlocks.
library;

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    this.count = 1,
    this.icon,
    this.description,
    this.category = 'general',
  });

  final String id;
  final String name;
  final int count;
  final String? icon;
  final String? description;
  final String category;

  InventoryItem copyWith({int? count}) => InventoryItem(
    id: id,
    name: name,
    count: count ?? this.count,
    icon: icon,
    description: description,
    category: category,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'count': count,
    if (icon != null) 'icon': icon,
    if (description != null) 'desc': description,
    'category': category,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] as String,
    name: json['name'] as String? ?? json['id'] as String,
    count: (json['count'] as num?)?.toInt() ?? 1,
    icon: json['icon'] as String?,
    description: json['desc'] as String?,
    category: json['category'] as String? ?? 'general',
  );
}

class EvidenceEntry {
  const EvidenceEntry({
    required this.id,
    required this.title,
    this.description = '',
    this.image,
    this.source,
    this.category = 'general',
    this.discoveredAt,
    this.linkedTo = const <String>[],
  });

  final String id;
  final String title;
  final String description;
  final String? image;
  final String? source;
  final String category;
  final DateTime? discoveredAt;
  final List<String> linkedTo;

  EvidenceEntry copyWith({List<String>? linkedTo}) => EvidenceEntry(
    id: id,
    title: title,
    description: description,
    image: image,
    source: source,
    category: category,
    discoveredAt: discoveredAt,
    linkedTo: linkedTo ?? this.linkedTo,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'desc': description,
    if (image != null) 'image': image,
    if (source != null) 'source': source,
    'category': category,
    if (discoveredAt != null) 'at': discoveredAt!.millisecondsSinceEpoch,
    'links': linkedTo,
  };

  factory EvidenceEntry.fromJson(Map<String, dynamic> json) => EvidenceEntry(
    id: json['id'] as String,
    title: json['title'] as String? ?? json['id'] as String,
    description: json['desc'] as String? ?? '',
    image: json['image'] as String?,
    source: json['source'] as String?,
    category: json['category'] as String? ?? 'general',
    discoveredAt: json['at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch((json['at'] as num).toInt()),
    linkedTo:
        (json['links'] as List<dynamic>?)
            ?.map((dynamic e) => e.toString())
            .toList() ??
        const <String>[],
  );
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.category = 'story',
    this.mood,
    this.image,
    this.pinned = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String category;
  final String? mood;
  final String? image;
  final bool pinned;

  JournalEntry copyWith({String? body, bool? pinned}) => JournalEntry(
    id: id,
    title: title,
    body: body ?? this.body,
    createdAt: createdAt,
    category: category,
    mood: mood,
    image: image,
    pinned: pinned ?? this.pinned,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    'at': createdAt.millisecondsSinceEpoch,
    'category': category,
    if (mood != null) 'mood': mood,
    if (image != null) 'image': image,
    'pinned': pinned,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['at'] as num?)?.toInt() ?? 0,
    ),
    category: json['category'] as String? ?? 'story',
    mood: json['mood'] as String?,
    image: json['image'] as String?,
    pinned: json['pinned'] as bool? ?? false,
  );
}

enum ObjectiveStatus { active, completed, failed }

class Objective {
  const Objective({
    required this.id,
    required this.title,
    this.description = '',
    this.status = ObjectiveStatus.active,
    this.optional = false,
    this.group = 'main',
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final ObjectiveStatus status;
  final bool optional;
  final String group;
  final DateTime? updatedAt;

  bool get isActive => status == ObjectiveStatus.active;

  Objective copyWith({ObjectiveStatus? status, DateTime? updatedAt}) =>
      Objective(
        id: id,
        title: title,
        description: description,
        status: status ?? this.status,
        optional: optional,
        group: group,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'desc': description,
    'status': status.name,
    'optional': optional,
    'group': group,
    if (updatedAt != null) 'at': updatedAt!.millisecondsSinceEpoch,
  };

  factory Objective.fromJson(Map<String, dynamic> json) => Objective(
    id: json['id'] as String,
    title: json['title'] as String? ?? json['id'] as String,
    description: json['desc'] as String? ?? '',
    status: ObjectiveStatus.values.firstWhere(
      (ObjectiveStatus s) => s.name == json['status'],
      orElse: () => ObjectiveStatus.active,
    ),
    optional: json['optional'] as bool? ?? false,
    group: json['group'] as String? ?? 'main',
    updatedAt: json['at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch((json['at'] as num).toInt()),
  );
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    this.description = '',
    this.icon,
    this.hidden = false,
    this.points = 10,
    this.unlockedAt,
    this.progress = 0,
    this.goal = 1,
  });

  final String id;
  final String title;
  final String description;
  final String? icon;
  final bool hidden;
  final int points;
  final DateTime? unlockedAt;
  final num progress;
  final num goal;

  bool get unlocked => unlockedAt != null;

  double get ratio => goal <= 0 ? 1 : (progress / goal).clamp(0, 1).toDouble();

  Achievement copyWith({DateTime? unlockedAt, num? progress, num? goal}) =>
      Achievement(
        id: id,
        title: title,
        description: description,
        icon: icon,
        hidden: hidden,
        points: points,
        unlockedAt: unlockedAt ?? this.unlockedAt,
        progress: progress ?? this.progress,
        goal: goal ?? this.goal,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'desc': description,
    if (icon != null) 'icon': icon,
    'hidden': hidden,
    'points': points,
    if (unlockedAt != null) 'at': unlockedAt!.millisecondsSinceEpoch,
    'progress': progress,
    'goal': goal,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] as String,
    title: json['title'] as String? ?? json['id'] as String,
    description: json['desc'] as String? ?? '',
    icon: json['icon'] as String?,
    hidden: json['hidden'] as bool? ?? false,
    points: (json['points'] as num?)?.toInt() ?? 10,
    unlockedAt: json['at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch((json['at'] as num).toInt()),
    progress: (json['progress'] as num?) ?? 0,
    goal: (json['goal'] as num?) ?? 1,
  );
}

class GalleryUnlock {
  const GalleryUnlock({
    required this.id,
    required this.title,
    required this.image,
    this.category = 'story',
    this.nsfw = false,
    this.unlockedAt,
    this.episode,
  });

  final String id;
  final String title;
  final String image;
  final String category;
  final bool nsfw;
  final DateTime? unlockedAt;
  final String? episode;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'image': image,
    'category': category,
    'nsfw': nsfw,
    if (unlockedAt != null) 'at': unlockedAt!.millisecondsSinceEpoch,
    if (episode != null) 'episode': episode,
  };

  factory GalleryUnlock.fromJson(Map<String, dynamic> json) => GalleryUnlock(
    id: json['id'] as String,
    title: json['title'] as String? ?? json['id'] as String,
    image: json['image'] as String? ?? '',
    category: json['category'] as String? ?? 'story',
    nsfw: json['nsfw'] as bool? ?? false,
    unlockedAt: json['at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch((json['at'] as num).toInt()),
    episode: json['episode'] as String?,
  );
}
