import 'dart:async';

import 'package:grumpy_flutter/grumpy_flutter.dart';

import 'modules.dart';
import 'repos.dart';

class ToggleGuard extends Guard<TestAppConfig> {
  final bool allowed;

  const ToggleGuard({required this.allowed, super.redirectTo});

  @override
  FutureOr<bool> canActivate(RouteContext context) => allowed;

  @override
  String toString() {
    return 'ToggleGuard(allowed: $allowed, redirectTo: $redirectTo)';
  }

  @override
  String get logTag => 'ToggleGuard';
}

class RepoGuard extends Guard<TestAppConfig> {
  const RepoGuard({super.redirectTo});

  @override
  FutureOr<bool> canActivate(RouteContext context) async {
    final repo = await Repo.get<GuardedRepo>();

    repo.data('guarded');
    return true;
  }

  @override
  String toString() {
    return 'TestRepoGuard(redirectTo: $redirectTo)';
  }

  @override
  String get logTag => 'RepoGuard';
}
