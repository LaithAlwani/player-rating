class GoalkeeperStats {
  final int diving;
  final int handling;
  final int kicking;
  final int reflexes;
  final int positioning;
  final int speed;

  GoalkeeperStats({
    required this.diving,
    required this.handling,
    required this.kicking,
    required this.reflexes,
    required this.positioning,
    required this.speed,
  });

  int get overall {
    final total = diving + handling + kicking + reflexes + speed + positioning;
    return (total / 6).round();
  }

  factory GoalkeeperStats.fromFirestore(Map<String, dynamic> data) {
    return GoalkeeperStats(
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

  GoalkeeperStats copyWith({
    int? diving,
    int? handling,
    int? kicking,
    int? reflexes,
    int? positioning,
    int? speed,
  }) {
    return GoalkeeperStats(
      diving: diving ?? this.diving,
      handling: handling ?? this.handling,
      kicking: kicking ?? this.kicking,
      reflexes: reflexes ?? this.reflexes,
      positioning: positioning ?? this.positioning,
      speed: speed ?? this.speed,
    );
  }
}
