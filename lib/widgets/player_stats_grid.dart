import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/models/field_player_stats.dart';
import 'package:lanus_academy/models/goal_keeper_stats.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/provider/home_view_model_provider.dart';
import 'package:lanus_academy/widgets/value_picker_bottom_sheet.dart';

class PlayerStatsGrid extends ConsumerWidget {
  const PlayerStatsGrid({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = user.stats;
    if (stats == null) return const Text("No stats available");

    final isGK = user.isGoalkeeper;
    final items = isGK
        ? [
            {
              "abbr": "DIV",
              "key": "diving",
              "arabic": "القفز",
              "value": stats.goalkeeper!.diving,
            },
            {
              "abbr": "HAD",
              "key": "handling",
              "arabic": "التعامل مع الكرة",
              "value": stats.goalkeeper!.handling,
            },
            {
              "abbr": "KIC",
              "key": "kicking",
              "arabic": "الركل",
              "value": stats.goalkeeper!.kicking,
            },
            {
              "abbr": "REF",
              "key": "reflexes",
              "arabic": "ردة الفعل",
              "value": stats.goalkeeper!.reflexes,
            },
            {
              "abbr": "SPE",
              "key": "speed",
              "arabic": "السرعة",
              "value": stats.goalkeeper!.speed,
            },
            {
              "abbr": "POS",
              "key": "positioning",
              "arabic": "التمركز",
              "value": stats.goalkeeper!.positioning,
            },
          ]
        : [
            {
              "abbr": "DRI",
              "key": "dribbling",
              "arabic": "المناورة",
              "value": stats.fieldPlayer!.dribbling,
            },
            {
              "abbr": "PAC",
              "key": "pace",
              "arabic": "السرعة",
              "value": stats.fieldPlayer!.pace,
            },
            {
              "abbr": "DEF",
              "key": "defending",
              "arabic": "الدفاع",
              "value": stats.fieldPlayer!.defending,
            },
            {
              "abbr": "SHO",
              "key": "shooting",
              "arabic": "التسديد",
              "value": stats.fieldPlayer!.shooting,
            },
            {
              "abbr": "PHY",
              "key": "physical",
              "arabic": "القوة البدنية",
              "value": stats.fieldPlayer!.physical,
            },
            {
              "abbr": "PAS",
              "key": "passing",
              "arabic": "التمرير",
              "value": stats.fieldPlayer!.passing,
            },
          ];

    return SizedBox(
      width: 250,
      child: Column(
        children: List.generate((items.length / 2).ceil(), (rowIndex) {
          final start = rowIndex * 2;
          final end = (start + 2).clamp(0, items.length);
          final rowItems = items.sublist(start, end);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: rowItems.map((item) {
              return StatTile(
                label: item["abbr"].toString(),
                value: item["value"] as int,
                onTap: (context, ref) => _onStatTap(
                  context,
                  ref,
                  user,
                  item["arabic"].toString(),
                  item["abbr"].toString(),
                  item["value"] as int,
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}

class StatTile extends ConsumerWidget {
  final String label;
  final int value;
  final void Function(BuildContext, WidgetRef) onTap;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (currentUser) {
        final canEdit = currentUser?.role == "admin";

        return GestureDetector(
          onTap: canEdit ? () => onTap(context, ref) : null,
          child: SizedBox(
            width: 120,
            // color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  Text(
                    "$label ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

Future<void> _onStatTap(
  BuildContext context,
  WidgetRef ref,
  AppUser user,
  String statKey,
  String label,
  int currentValue,
) async {
  final homeVM = ref.read(homeViewModelProvider.notifier);

  await showValuePickerBottomSheet(
    context: context,
    title: statKey.toUpperCase(),
    initialValue: currentValue,
    onSave: (newValue) async {
      final updatedStats = user.stats!.copywith(
        fieldPlayer: user.isGoalkeeper
            ? null
            : updatedFP(user.stats!.fieldPlayer!, statKey, newValue),
        goalkeeper: user.isGoalkeeper
            ? updatedGK(user.stats!.goalkeeper!, statKey, newValue)
            : null,
      );

      await homeVM.updateUser(user.uid, {"stats": updatedStats});
      homeVM.updateLocalPlayer(user.copyWith(stats: updatedStats));
    },
  );
}

/// Helper functions to update stats
GoalkeeperStats updatedGK(GoalkeeperStats old, String key, int value) {
  switch (key) {
    case "diving":
      return old.copyWith(diving: value);
    case "handling":
      return old.copyWith(handling: value);
    case "kicking":
      return old.copyWith(kicking: value);
    case "reflexes":
      return old.copyWith(reflexes: value);
    case "speed":
      return old.copyWith(speed: value);
    case "positioning":
      return old.copyWith(positioning: value);
    default:
      return old;
  }
}

FieldPlayerStats updatedFP(FieldPlayerStats old, String key, int value) {
  switch (key) {
    case "dribbling":
      return old.copyWith(dribbling: value);
    case "pace":
      return old.copyWith(pace: value);
    case "defending":
      return old.copyWith(defending: value);
    case "shooting":
      return old.copyWith(shooting: value);
    case "physical":
      return old.copyWith(physical: value);
    case "passing":
      return old.copyWith(passing: value);
    default:
      return old;
  }
}
