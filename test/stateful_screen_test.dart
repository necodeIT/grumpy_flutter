import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';

void main() {
  const firstRoute = RouteContext(fullPath: '/first');
  const secondRoute = RouteContext(fullPath: '/second');

  group('StatefulScreenContent', () {
    testWidgets('works independently and receives the route', (tester) async {
      final tracker = _LifecycleTracker();
      final screen = _ContentScreen(tracker);

      await _pumpScreen(
        tester,
        screen: screen,
        route: firstRoute,
        phase: _ScreenPhase.content,
      );

      expect(find.text('content /first taps: 0'), findsOneWidget);
      expect(tracker.contentCreated, 1);
      expect(tracker.previewCreated, 0);
    });

    testWidgets('preserves state and exposes an updated route', (tester) async {
      final tracker = _LifecycleTracker();
      final screen = _ContentScreen(tracker);

      await _pumpScreen(
        tester,
        screen: screen,
        route: firstRoute,
        phase: _ScreenPhase.content,
      );
      await tester.tap(find.text('increment content'));
      await tester.pump();

      await _pumpScreen(
        tester,
        screen: screen,
        route: secondRoute,
        phase: _ScreenPhase.content,
      );

      expect(find.text('content /second taps: 1'), findsOneWidget);
      expect(tracker.contentCreated, 1);
      expect(tracker.contentDisposed, 0);
    });

    testWidgets('uses its key hook to replace content state', (tester) async {
      final tracker = _LifecycleTracker();
      final screen = _ContentScreen(tracker, keyByRoute: true);

      await _pumpScreen(
        tester,
        screen: screen,
        route: firstRoute,
        phase: _ScreenPhase.content,
      );
      await tester.tap(find.text('increment content'));
      await tester.pump();

      await _pumpScreen(
        tester,
        screen: screen,
        route: secondRoute,
        phase: _ScreenPhase.content,
      );

      expect(find.text('content /second taps: 0'), findsOneWidget);
      expect(tracker.contentCreated, 2);
      expect(tracker.contentDisposed, 1);
      expect(tracker.previewCreated, 0);
    });
  });

  group('StatefulScreenPreview', () {
    testWidgets('works independently and receives the route', (tester) async {
      final tracker = _LifecycleTracker();
      final screen = _PreviewScreen(tracker);

      await _pumpScreen(
        tester,
        screen: screen,
        route: firstRoute,
        phase: _ScreenPhase.preview,
      );

      expect(find.text('preview /first taps: 0'), findsOneWidget);
      expect(tracker.previewCreated, 1);
      expect(tracker.contentCreated, 0);
    });

    testWidgets('preserves state and exposes an updated route', (tester) async {
      final tracker = _LifecycleTracker();
      final screen = _PreviewScreen(tracker);

      await _pumpScreen(
        tester,
        screen: screen,
        route: firstRoute,
        phase: _ScreenPhase.preview,
      );
      await tester.tap(find.text('increment preview'));
      await tester.pump();

      await _pumpScreen(
        tester,
        screen: screen,
        route: secondRoute,
        phase: _ScreenPhase.preview,
      );

      expect(find.text('preview /second taps: 1'), findsOneWidget);
      expect(tracker.previewCreated, 1);
      expect(tracker.previewDisposed, 0);
    });

    testWidgets('uses its key hook to replace preview state', (tester) async {
      final tracker = _LifecycleTracker();
      final screen = _PreviewScreen(tracker, keyByRoute: true);

      await _pumpScreen(
        tester,
        screen: screen,
        route: firstRoute,
        phase: _ScreenPhase.preview,
      );
      await tester.tap(find.text('increment preview'));
      await tester.pump();

      await _pumpScreen(
        tester,
        screen: screen,
        route: secondRoute,
        phase: _ScreenPhase.preview,
      );

      expect(find.text('preview /second taps: 0'), findsOneWidget);
      expect(tracker.previewCreated, 2);
      expect(tracker.previewDisposed, 1);
      expect(tracker.contentCreated, 0);
    });
  });

  testWidgets('combined mixins use separate state lifecycles', (tester) async {
    final tracker = _LifecycleTracker();
    final screen = _StatefulScreen(tracker);

    await _pumpScreen(
      tester,
      screen: screen,
      route: firstRoute,
      phase: _ScreenPhase.preview,
    );

    expect(find.byType(StatefulScreenPreviewComponent), findsOneWidget);
    expect(tracker.previewCreated, 1);
    expect(tracker.previewDisposed, 0);
    expect(tracker.contentCreated, 0);

    await _pumpScreen(
      tester,
      screen: screen,
      route: firstRoute,
      phase: _ScreenPhase.content,
    );

    expect(find.byType(StatefulScreenContentComponent), findsOneWidget);
    expect(find.byType(StatefulScreenPreviewComponent), findsNothing);
    expect(tracker.previewDisposed, 1);
    expect(tracker.contentCreated, 1);
    expect(tracker.contentDisposed, 0);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required Screen screen,
  required RouteContext route,
  required _ScreenPhase phase,
}) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: _ScreenHost(screen: screen, route: route, phase: phase),
    ),
  );
}

enum _ScreenPhase { content, preview }

class _ScreenHost extends StatelessWidget {
  const _ScreenHost({
    required this.screen,
    required this.route,
    required this.phase,
  });

  final Screen screen;
  final RouteContext route;
  final _ScreenPhase phase;

  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      _ScreenPhase.content => screen.buildContent(context, route),
      _ScreenPhase.preview => screen.buildPreview(context, route),
    };
  }
}

class _LifecycleTracker {
  int contentCreated = 0;
  int contentDisposed = 0;
  int previewCreated = 0;
  int previewDisposed = 0;
}

class _ContentScreen extends Screen with StatefulScreenContent {
  const _ContentScreen(this.tracker, {this.keyByRoute = false});

  final _LifecycleTracker tracker;
  final bool keyByRoute;

  @override
  ScreenContentState createContentState() {
    tracker.contentCreated++;
    return _ContentState(tracker);
  }

  @override
  Key? createContentKey(RouteContext route) {
    return keyByRoute ? ValueKey(route.fullPath) : null;
  }

  @override
  Widget buildPreview(BuildContext context, RouteContext route) {
    return Text('plain preview ${route.fullPath}');
  }
}

class _PreviewScreen extends Screen with StatefulScreenPreview {
  const _PreviewScreen(this.tracker, {this.keyByRoute = false});

  final _LifecycleTracker tracker;
  final bool keyByRoute;

  @override
  Widget buildContent(BuildContext context, RouteContext route) {
    return Text('plain content ${route.fullPath}');
  }

  @override
  ScreenPreviewState createPreviewState() {
    tracker.previewCreated++;
    return _PreviewState(tracker);
  }

  @override
  Key? createPreviewKey(RouteContext route) {
    return keyByRoute ? ValueKey(route.fullPath) : null;
  }
}

class _StatefulScreen extends Screen
    with StatefulScreenContent, StatefulScreenPreview {
  const _StatefulScreen(this.tracker);

  final _LifecycleTracker tracker;

  @override
  ScreenContentState createContentState() {
    tracker.contentCreated++;
    return _ContentState(tracker);
  }

  @override
  ScreenPreviewState createPreviewState() {
    tracker.previewCreated++;
    return _PreviewState(tracker);
  }
}

class _ContentState extends ScreenContentState {
  _ContentState(this.tracker);

  final _LifecycleTracker tracker;
  int taps = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('content ${widget.route.fullPath} taps: $taps'),
        GestureDetector(
          onTap: () => setState(() => taps++),
          child: const Text('increment content'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    tracker.contentDisposed++;
    super.dispose();
  }
}

class _PreviewState extends ScreenPreviewState {
  _PreviewState(this.tracker);

  final _LifecycleTracker tracker;
  int taps = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('preview ${widget.route.fullPath} taps: $taps'),
        GestureDetector(
          onTap: () => setState(() => taps++),
          child: const Text('increment preview'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    tracker.previewDisposed++;
    super.dispose();
  }
}
