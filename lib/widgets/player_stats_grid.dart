import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/models/app_user.dart';
import 'package:lanus_academy/models/field_player_stats.dart';
import 'package:lanus_academy/models/goal_keeper_stats.dart';
import 'package:lanus_academy/provider/auth_provider.dart';
import 'package:lanus_academy/provider/home_view_model_provider.dart';

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
            {"abbr": "DIV", "key": "diving", "value": stats.goalkeeper!.diving},
            {
              "abbr": "HAD",
              "key": "handling",
              "value": stats.goalkeeper!.handling,
            },
            {
              "abbr": "KIC",
              "key": "kicking",
              "value": stats.goalkeeper!.kicking,
            },
            {
              "abbr": "REF",
              "key": "reflexes",
              "value": stats.goalkeeper!.reflexes,
            },
            {"abbr": "SPE", "key": "speed", "value": stats.goalkeeper!.speed},
            {
              "abbr": "POS",
              "key": "positioning",
              "value": stats.goalkeeper!.positioning,
            },
          ]
        : [
            {
              "abbr": "DRI",
              "key": "dribbling",
              "value": stats.fieldPlayer!.dribbling,
            },
            {"abbr": "PAC", "key": "pace", "value": stats.fieldPlayer!.pace},
            {
              "abbr": "DEF",
              "key": "defending",
              "value": stats.fieldPlayer!.defending,
            },
            {
              "abbr": "SHO",
              "key": "shooting",
              "value": stats.fieldPlayer!.shooting,
            },
            {
              "abbr": "PHY",
              "key": "physical",
              "value": stats.fieldPlayer!.physical,
            },
            {
              "abbr": "PAS",
              "key": "passing",
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowItems.map((item) {
              return StatTile(
                label: item["abbr"].toString(),
                value: item["value"] as int,
                onTap: (context, ref) => _onStatTap(
                  context,
                  ref,
                  user,
                  item["key"].toString(),
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
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {
      int tempValue = currentValue;
      bool isSaving = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SizedBox(
              height: 350,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      perspective: 0.003,
                      controller: FixedExtentScrollController(
                        initialItem: currentValue - 1,
                      ),
                      onSelectedItemChanged: (index) =>
                          setState(() => tempValue = index + 1),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index >= 99) return null;
                          return Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontSize: (index + 1) == tempValue ? 28 : 22,
                                fontWeight: (index + 1) == tempValue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: (index + 1) == tempValue
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xFF37569a),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                setState(() => isSaving = true);

                                final updatedStats = user.stats!.copywith(
                                  fieldPlayer: user.isGoalkeeper
                                      ? null
                                      : updatedFP(
                                          user.stats!.fieldPlayer!,
                                          statKey,
                                          tempValue,
                                        ),
                                  goalkeeper: user.isGoalkeeper
                                      ? updatedGK(
                                          user.stats!.goalkeeper!,
                                          statKey,
                                          tempValue,
                                        )
                                      : null,
                                );

                                await homeVM.updateUser(user.uid, {
                                  "stats": updatedStats,
                                });
                                homeVM.updateLocalPlayer(
                                  user.copyWith(stats: updatedStats),
                                );

                                if (context.mounted) Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("✅ تم الحفظ بنجاح"),
                                  ),
                                );
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("حفظ", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
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
