import 'package:flutter_riverpod/legacy.dart';
import 'package:lanus_academy/viewmodels/home_viewmodel.dart';

final homeViewModelProvider = ChangeNotifierProvider<HomeViewModel>((ref) {
  final vm = HomeViewModel();
  vm.loadInitial(); // automatically load players
  return vm;
});
