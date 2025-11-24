import 'package:lanus_academy/models/field_player_stats.dart';
import 'package:lanus_academy/models/goal_keeper_stats.dart';

class PlayerStats {
  final FieldPlayerStats? fieldPlayer;
  final GoalKeeperStats? goalkeeper;

  PlayerStats({this.fieldPlayer, this.goalkeeper});

  bool get isGoalKeeper => goalkeeper != null;

  factory PlayerStats.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return PlayerStats();

    return PlayerStats(
      fieldPlayer: data['fieldPlayer'] != null
          ? FieldPlayerStats.fromFirestore(data['fieldPlayer'])
          : null,
      goalkeeper: data['goalkeeper'] != null
          ? GoalKeeperStats.fromFirestore(data['goalkeeper'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (fieldPlayer != null) 'fieldPlayer': fieldPlayer!.toFirestore(),
      if (goalkeeper != null) 'goalkeeper': goalkeeper!.toFirestore(),
    };
  }

  PlayerStats copywith({
    FieldPlayerStats? fieldPlayer,
    GoalKeeperStats? goalkeeper,
  }) {
    return PlayerStats(
      fieldPlayer: fieldPlayer ?? this.fieldPlayer,
      goalkeeper: goalkeeper ?? this.goalkeeper,
    );
  }
}
