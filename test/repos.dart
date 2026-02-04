import 'package:grumpy/grumpy.dart';

class TestRepo extends Repo<String> {
  // false positive
  // ignore: call_initialize_in_constructor
  TestRepo();

  @override
  String get logTag => 'TestRepo';
}

class GuardedRepo extends Repo<String> {
  GuardedRepo(String initial) {
    data(initial);
    initialize();
  }

  @override
  String get logTag => 'GuardedRepo';
}
