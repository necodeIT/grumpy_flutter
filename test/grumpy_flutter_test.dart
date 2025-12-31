import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'modules.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // this is not production code; it's just for test logging
    // ignore: avoid_print
    print(record);
  });
  late TestApp testApp;

  setUp(() async {
    testApp = TestApp();
    await testApp.initialize();
  });

  tearDown(() {
    GetIt.I.reset(dispose: false);
    TestModule.resetTrackers();
    DummyModule.resetTrackers();
  });
  group('Routing', () {
    testWidgets('renders initial view', (WidgetTester tester) async {
      await tester.pumpWidget(testApp.buildApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.textContaining('initial view'), findsOneWidget);
    });

    testWidgets('navigation renders preview first', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testApp.buildApp());

      expect(find.textContaining('Preview'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.textContaining('Content'), findsOneWidget);
    });

    testWidgets('routing using go works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp.buildApp());

      testApp.goRouter.go('/shellsc');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.textContaining('shell'), findsOneWidget);
    });

    testWidgets('routing into a different Module works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testApp.buildApp());

      testApp.goRouter.go('/dummy/dummysc');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.textContaining('dummy'), findsOneWidget);
    });

    testWidgets('navigating to a route activates all dependenies', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testApp.buildApp());

      testApp.goRouter.go('/test/init');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.textContaining('init'), findsOneWidget);
      expect(TestModule.activationCount, 1);
      expect(DummyModule.activationCount, 1);
    });
  });

  group('Components', () {
    group('StatefulComponent', () {});
    group('QueryComponent', () {});
    group('StatefulQueryContent', () {});
    group('StatefulQueryError', () {});
    group('StatefulQueryLoader', () {});
  });

  group('Guards', () {});
}
