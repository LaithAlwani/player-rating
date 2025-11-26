import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanus_academy/models/app_user.dart';

import '../viewmodels/auth_viewmodel.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(
  () => AuthNotifier(),
);
