/// Relationship axes tracked per character.
library;

enum RelationshipAxis { trust, friendship, love, tension, suspicion }

RelationshipAxis? relationshipAxisFromName(String name) {
  switch (name.toLowerCase()) {
    case 'trust':
      return RelationshipAxis.trust;
    case 'friendship':
    case 'friend':
      return RelationshipAxis.friendship;
    case 'love':
    case 'romance':
      return RelationshipAxis.love;
    case 'tension':
      return RelationshipAxis.tension;
    case 'suspicion':
      return RelationshipAxis.suspicion;
    default:
      return null;
  }
}

class Relationship {
  const Relationship({
    required this.characterId,
    this.trust = 0,
    this.friendship = 0,
    this.love = 0,
    this.tension = 0,
    this.suspicion = 0,
  });

  final String characterId;
  final num trust;
  final num friendship;
  final num love;
  final num tension;
  final num suspicion;

  static const num min = -100;
  static const num max = 100;

  num axis(RelationshipAxis axis) {
    switch (axis) {
      case RelationshipAxis.trust:
        return trust;
      case RelationshipAxis.friendship:
        return friendship;
      case RelationshipAxis.love:
        return love;
      case RelationshipAxis.tension:
        return tension;
      case RelationshipAxis.suspicion:
        return suspicion;
    }
  }

  Relationship withAxis(RelationshipAxis axis, num value) {
    final num clamped = value < min ? min : (value > max ? max : value);
    switch (axis) {
      case RelationshipAxis.trust:
        return copyWith(trust: clamped);
      case RelationshipAxis.friendship:
        return copyWith(friendship: clamped);
      case RelationshipAxis.love:
        return copyWith(love: clamped);
      case RelationshipAxis.tension:
        return copyWith(tension: clamped);
      case RelationshipAxis.suspicion:
        return copyWith(suspicion: clamped);
    }
  }

  Relationship copyWith({
    num? trust,
    num? friendship,
    num? love,
    num? tension,
    num? suspicion,
  }) => Relationship(
    characterId: characterId,
    trust: trust ?? this.trust,
    friendship: friendship ?? this.friendship,
    love: love ?? this.love,
    tension: tension ?? this.tension,
    suspicion: suspicion ?? this.suspicion,
  );

  /// Rough label used by the Contacts app and the journal.
  String get bondLabel {
    final num score = (trust + friendship + love) / 3;
    if (love >= 60) return 'Entangled';
    if (score >= 50) return 'Close';
    if (score >= 20) return 'Warm';
    if (score > -10) return 'Neutral';
    if (score > -40) return 'Strained';
    return 'Broken';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': characterId,
    'trust': trust,
    'friendship': friendship,
    'love': love,
    'tension': tension,
    'suspicion': suspicion,
  };

  factory Relationship.fromJson(Map<String, dynamic> json) => Relationship(
    characterId: json['id'] as String,
    trust: (json['trust'] as num?) ?? 0,
    friendship: (json['friendship'] as num?) ?? 0,
    love: (json['love'] as num?) ?? 0,
    tension: (json['tension'] as num?) ?? 0,
    suspicion: (json['suspicion'] as num?) ?? 0,
  );
}
