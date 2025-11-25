import 'package:lanus_academy/models/field_player_stats.dart';
import 'package:lanus_academy/models/goal_keeper_stats.dart';

class PlayerStats {
  final FieldPlayerStats? fieldPlayer;
  final GoalkeeperStats? goalkeeper;

  PlayerStats({this.fieldPlayer, this.goalkeeper});

  int get overall {
    if (fieldPlayer != null) {
      return fieldPlayer!.overall;
    } else if (goalkeeper != null) {
      return goalkeeper!.overall;
    } else {
      return 0;
    }
  }

  factory PlayerStats.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return PlayerStats();

    return PlayerStats(
      fieldPlayer: data['fieldPlayer'] != null
          ? FieldPlayerStats.fromFirestore(data['fieldPlayer'])
          : null,
      goalkeeper: data['goalkeeper'] != null
          ? GoalkeeperStats.fromFirestore(data['goalkeeper'])
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
    GoalkeeperStats? goalkeeper,
  }) {
    return PlayerStats(
      fieldPlayer: fieldPlayer ?? this.fieldPlayer,
      goalkeeper: goalkeeper ?? this.goalkeeper,
    );
  }

  PlayerStats merge(Map<String, dynamic> data) {
    return copywith(
      fieldPlayer: data['fieldPlayer'] != null
          ? fieldPlayer!.merge(data['fieldPlayer'])
          : fieldPlayer,
      goalkeeper: data['goalkeeper'] != null
          ? goalkeeper!.merge(data['goalkeeper'])
          : goalkeeper,
    );
  }
}
