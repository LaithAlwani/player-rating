class FieldPlayerStats {
  final int passing;
  final int shooting;
  final int dribbling;
  final int physical;
  final int defending;
  final int pace;

  FieldPlayerStats({
    required this.passing,
    required this.shooting,
    required this.dribbling,
    required this.physical,
    required this.defending,
    required this.pace,
  });

  int get overall {
    final total = shooting + passing + pace + dribbling + defending + physical;
    return (total / 6).round();
  }

  factory FieldPlayerStats.fromFirestore(Map<String, dynamic> data) {
    return FieldPlayerStats(
      passing: data['passing'],
      shooting: data['shooting'],
      dribbling: data['dribbling'],
      physical: data['physical'],
      defending: data['defending'],
      pace: data['pace'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'passing': passing,
      'shooting': shooting,
      'dribbling': dribbling,
      'physical': physical,
      'defending': defending,
      'pace': pace,
    };
  }

  FieldPlayerStats copyWith({
    int? passing,
    int? shooting,
    int? dribbling,
    int? physical,
    int? defending,
    int? pace,
  }) {
    return FieldPlayerStats(
      passing: passing ?? this.passing,
      shooting: shooting ?? this.shooting,
      dribbling: dribbling ?? this.dribbling,
      physical: physical ?? this.physical,
      defending: defending ?? this.defending,
      pace: pace ?? this.pace,
    );
  }
}
