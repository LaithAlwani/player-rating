
class GoalKeeperStats {
  final int diving;
  final int handling;
  final int kicking;
  final int reflexes;
  final int positioning;
  final int speed;

  GoalKeeperStats({
    required this.diving,
    required this.handling,
    required this.kicking,
    required this.reflexes,
    required this.positioning,
    required this.speed,
  });

  factory GoalKeeperStats.fromFirestore(Map<String, dynamic> data) {
    return GoalKeeperStats(
      diving: data['diving'],
      handling: data['handling'],
      kicking: data['kicking'],
      reflexes: data['reflexes'],
      positioning: data['positioning'],
      speed: data['speed'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'diving': diving,
      'handling': handling,
      'kicking': kicking,
      'reflexes': reflexes,
      'positioning': positioning,
      'speed': speed,
    };
  }

  GoalKeeperStats copyWith({
    int? diving,
    int? handling,
    int? kicking,
    int? reflexes,
    int? positioning,
    int? speed,
  }) {
    return GoalKeeperStats(
      diving: diving ?? this.diving,
      handling: handling ?? this.handling,
      kicking: kicking ?? this.kicking,
      reflexes: reflexes ?? this.reflexes,
      positioning: positioning ?? this.positioning,
      speed: speed ?? this.speed,
    );
  }
}
