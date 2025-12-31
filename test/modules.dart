import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';

import 'screens.dart';

class TestAppConfig {
  final String appName;

  const TestAppConfig({required this.appName});
}

class TestApp extends AppModule<TestAppConfig> {
  // initialize is called from outside
  // ignore: call_initialize_in_constructor
  TestApp() : super(const TestAppConfig(appName: 'TestApp'));

  @override
  List<FlutterRoute<TestAppConfig>> get routes => [
    ModuleRoute<TestAppConfig>(path: '/test', module: TestModule()),
    ModuleRoute<TestAppConfig>(path: '/dummy', module: DummyModule()),
    ShellScreenRoute(
      shellBuilder: (_, _, child) => Column(
        children: [
          const Text('Shell Header'),
          Expanded(child: child),
          const Text('Shell Footer'),
        ],
      ),
      children: [
        ScreenRoute<TestAppConfig>(
          path: '/shellsc',
          view: DummyScreen('shell'),
        ),
        ScreenRoute<TestAppConfig>(
          path: '/init',
          view: DummyScreen('initial view'),
        ),
      ],
    ),
  ];

  @override
  // TODO: implement initialLocation
  String get initialLocation => '/init';

  @override
  Screen get notFoundScreen => NotFoundScreen();

  @override
  FutureOr<void> activate() async {
    await super.activate();
  }

  @override
  FutureOr<void> deactivate() async {
    await super.deactivate();
  }

  @override
  FutureOr<void> dependenciesChanged() {}

  Widget buildApp() {
    return MaterialApp.router(routerConfig: goRouter);
  }
}

class DummyModule extends Module<TestAppConfig> {
  @override
  List<FlutterRoute<TestAppConfig>> get routes => [
    ScreenRoute<TestAppConfig>(path: '/dummysc', view: DummyScreen('dummy')),
  ];

  static int activationCount = 0;

  @override
  FutureOr<void> activate() async {
    await super.activate();
    activationCount++;
  }

  @override
  FutureOr<void> dependenciesChanged() {}

  static void resetTrackers() {
    activationCount = 0;
  }
}

class TestModule extends Module<TestAppConfig> {
  static int activationCount = 0;

  @override
  List<Module<TestAppConfig>> get imports => [DummyModule()];

  @override
  List<FlutterRoute<TestAppConfig>> get routes => [
    ScreenRoute<TestAppConfig>(path: '/init', view: DummyScreen('init')),
  ];

  @override
  FutureOr<void> activate() async {
    await super.activate();
    activationCount++;
  }

  @override
  FutureOr<void> dependenciesChanged() {}

  static void resetTrackers() {
    activationCount = 0;
  }
}
