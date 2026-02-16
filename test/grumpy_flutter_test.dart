import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';

import 'components.dart';
import 'guards.dart';
import 'modules.dart';
import 'repos.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // this is not production code; it's just for test logging
    // ignore: avoid_print
    print(record);
  });

  group('Routing', () {
    late TestApp testApp;

    setUp(() async {
      testApp = TestApp();
      await testApp.initialize();
      await testApp.activate();
    });

    tearDown(() {
      GetIt.I.reset(dispose: false);
      TestModule.resetTrackers();
      DummyModule.resetTrackers();
    });

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
      for (var i = 0; i < 50; i++) {
        if (TestModule.activationCount == 1 &&
            DummyModule.activationCount == 1) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(TestModule.activationCount, 1);
      expect(DummyModule.activationCount, 1);
    });
  });

  group('Components', () {
    setUp(() {
      GetIt.I.reset(dispose: false);
    });

    tearDown(() {
      GetIt.I.reset(dispose: false);
    });

    group('QueryComponent', () {
      testWidgets('renders loading state while waiting for data', (
        WidgetTester tester,
      ) async {
        final repo = TestRepo();
        GetIt.I.registerSingleton<TestRepo>(repo);

        await tester.pumpWidget(
          const MaterialApp(home: BaseStringQueryComponent(label: 'query')),
        );

        await tester.pump();

        expect(find.text('query-loader'), findsOneWidget);
      });

      testWidgets('renders error when query fails', (
        WidgetTester tester,
      ) async {
        final repo = TestRepo();
        GetIt.I.registerSingletonAsync<TestRepo>(() async {
          await repo.initialize();
          return repo;
        });

        await tester.pumpWidget(
          const MaterialApp(home: BaseStringQueryComponent(label: 'query')),
        );

        repo.error('boom');
        await tester.pump(const Duration(seconds: 5));

        expect(find.text('query-error: boom'), findsOneWidget);
      });

      testWidgets('renders content when query returns data', (
        WidgetTester tester,
      ) async {
        final repo = TestRepo();
        GetIt.I.registerSingletonAsync<TestRepo>(() async {
          await repo.initialize();
          return repo;
        });

        repo.data('hello');

        await tester.pumpWidget(
          const MaterialApp(home: BaseStringQueryComponent(label: 'query')),
        );

        await tester.pumpAndSettle();

        expect(find.text('query-content: hello'), findsOneWidget);
      });

      testWidgets('renders new content when repo changes data', (
        WidgetTester tester,
      ) async {
        final repo = TestRepo();
        GetIt.I.registerSingletonAsync<TestRepo>(() async {
          await repo.initialize();
          return repo;
        });

        repo.data('first');

        await tester.pumpWidget(
          const MaterialApp(home: BaseStringQueryComponent(label: 'query')),
        );
        await tester.pumpAndSettle();

        expect(find.text('query-content: first'), findsOneWidget);

        repo.data('second');
        await tester.pump();
        await tester.pump();

        expect(find.text('query-content: second'), findsOneWidget);
        expect(find.text('query-content: first'), findsNothing);
      });

      group('StatefulQueryContent', () {
        testWidgets('renders content when query returns data', (
          WidgetTester tester,
        ) async {
          final repo = TestRepo();
          GetIt.I.registerSingletonAsync<TestRepo>(() async {
            await repo.initialize();
            return repo;
          });
          repo.data('stateful content');

          await tester.pumpWidget(
            const MaterialApp(
              home: StatefulContentQueryComponent(label: 'stateful'),
            ),
          );

          await tester.pumpAndSettle();

          expect(
            find.text('stateful-content: stateful content'),
            findsOneWidget,
          );
          expect(find.text('content taps: 0'), findsOneWidget);
        });

        testWidgets('changes state and keeps data', (
          WidgetTester tester,
        ) async {
          final repo = TestRepo();
          GetIt.I.registerSingletonAsync<TestRepo>(() async {
            await repo.initialize();
            return repo;
          });
          repo.data('stateful content');

          await tester.pumpWidget(
            const MaterialApp(
              home: StatefulContentQueryComponent(label: 'stateful'),
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('toggle content'));
          await tester.pump();

          expect(
            find.text('stateful-content: stateful content'),
            findsOneWidget,
          );
          expect(find.text('content taps: 1'), findsOneWidget);
        });
      });
      group('StatefulQueryError', () {
        testWidgets('renders error when query fails', (
          WidgetTester tester,
        ) async {
          final repo = TestRepo();
          GetIt.I.registerSingletonAsync<TestRepo>(() async {
            await repo.initialize();
            return repo;
          });

          await tester.pumpWidget(
            const MaterialApp(
              home: StatefulErrorQueryComponent(label: 'error'),
            ),
          );

          repo.error('oops');
          await tester.pump();

          expect(find.text('error-state: oops'), findsOneWidget);
          expect(find.text('error taps: 0'), findsOneWidget);
        });

        testWidgets('changes state and keeps error', (
          WidgetTester tester,
        ) async {
          final repo = TestRepo();
          GetIt.I.registerSingletonAsync<TestRepo>(() async {
            await repo.initialize();
            return repo;
          });

          await tester.pumpWidget(
            const MaterialApp(
              home: StatefulErrorQueryComponent(label: 'error'),
            ),
          );
          repo.error('oops');
          await tester.pump();

          await tester.tap(find.text('inspect error'));
          await tester.pump();

          expect(find.text('error-state: oops'), findsOneWidget);
          expect(find.text('error taps: 1'), findsOneWidget);
        });
      });
      group('StatefulQueryLoader', () {
        testWidgets('renders loading state while waiting for data', (
          WidgetTester tester,
        ) async {
          final repo = TestRepo();
          GetIt.I.registerSingletonAsync<TestRepo>(() async {
            await repo.initialize();
            return repo;
          });

          await tester.pumpWidget(
            const MaterialApp(
              home: StatefulLoaderQueryComponent(label: 'loader'),
            ),
          );
          await tester.pump();

          expect(find.text('loader-loading taps: 0'), findsOneWidget);
        });

        testWidgets('changes state and keeps loading', (
          WidgetTester tester,
        ) async {
          final repo = TestRepo();
          GetIt.I.registerSingletonAsync<TestRepo>(() async {
            await repo.initialize();
            return repo;
          });

          await tester.pumpWidget(
            const MaterialApp(
              home: StatefulLoaderQueryComponent(label: 'loader'),
            ),
          );
          await tester.pump();

          await tester.tap(find.text('nudge loader'));
          await tester.pump();

          expect(find.text('loader-loading taps: 1'), findsOneWidget);
        });
      });
    });
  });

  group('Guards', () {
    setUp(() {
      GetIt.I.reset(dispose: false);
    });

    tearDown(() {
      GetIt.I.reset(dispose: false);
    });

    testWidgets('screen renders when guard passes', (
      WidgetTester tester,
    ) async {
      final guard = const ToggleGuard(allowed: true);
      final app = await bootstrapGuardedApp(guard);

      await tester.pumpWidget(app.buildApp());

      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.textContaining('guarded-screen'), findsOneWidget);
    });

    testWidgets('can access repos from guarded module', (
      WidgetTester tester,
    ) async {
      final app = await bootstrapGuardedApp(
        const RepoGuard(),
        initialData: 'module repo data',
      );

      final repo = await Repo.get<GuardedRepo>();

      await tester.pumpWidget(app.buildApp());

      expect(repo.state.hasData, isTrue);
      expect(repo.state.requireData, 'guarded');
    });

    testWidgets('screen content does not render when guard fails', (
      tester,
    ) async {
      final guard = const ToggleGuard(allowed: false);
      final app = await bootstrapGuardedApp(guard, initialRoute: '/redirect');

      await tester.pumpWidget(app.buildApp());
      await tester.pump();

      app.goRouter.go('/guarded/screen');

      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.textContaining('guarded-screen-content'), findsNothing);
      expect(find.textContaining('guarded-screen-preview'), findsOne);
    });

    testWidgets('redirects when guard fails with specified redirect', (
      WidgetTester tester,
    ) async {
      final guard = const ToggleGuard(allowed: false, redirectTo: '/redirect');
      final app = await bootstrapGuardedApp(guard);

      await tester.pumpWidget(app.buildApp());

      await tester.pumpAndSettle();

      expect(find.textContaining('redirect'), findsOneWidget);
    });
  });
}

Future<GuardedApp> bootstrapGuardedApp(
  Guard<TestAppConfig> guard, {
  String initialData = 'guarded repo data',
  String initialRoute = '/guarded/screen',
}) async {
  final module = GuardedModule(guard: guard, initialData: initialData);
  final app = GuardedApp(module, initialRoute);
  await app.initialize();
  await app.activate();
  return app;
}
