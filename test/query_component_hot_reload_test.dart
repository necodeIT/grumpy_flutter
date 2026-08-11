import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';

void main() {
  testWidgets('rebuilds content and reruns its query after hot reload', (
    WidgetTester tester,
  ) async {
    _HotReloadQueryComponent.queryVersion = 'query-v1';
    _HotReloadQueryComponent.contentVersion = 'content-v1';
    _HotReloadQueryComponent.queryCalls = 0;

    await tester.pumpWidget(
      const MaterialApp(home: _HotReloadQueryComponent()),
    );
    await tester.pumpAndSettle();

    expect(find.text('query-v1 content-v1'), findsOneWidget);
    expect(_HotReloadQueryComponent.queryCalls, 1);

    _HotReloadQueryComponent.queryVersion = 'query-v2';
    _HotReloadQueryComponent.contentVersion = 'content-v2';

    final reassembly = tester.binding.reassembleApplication();
    await tester.pump();
    await reassembly;
    await tester.pumpAndSettle();

    expect(find.text('query-v2 content-v2'), findsOneWidget);
    expect(find.text('query-v1 content-v1'), findsNothing);
    expect(_HotReloadQueryComponent.queryCalls, 2);
  });
}

/// A query component whose mutable versions stand in for hot-reloaded code.
class _HotReloadQueryComponent extends QueryComponent<String> {
  /// Creates the component used by the hot-reload regression test.
  const _HotReloadQueryComponent();

  /// The value returned by the simulated current query implementation.
  static String queryVersion = 'query-v1';

  /// The value rendered by the simulated current content implementation.
  static String contentVersion = 'content-v1';

  /// The number of times the simulated query implementation has run.
  static int queryCalls = 0;

  @override
  Widget buildContent(BuildContext context, String data) {
    return Text('$data $contentVersion');
  }

  @override
  Widget buildError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Text('error: $error');
  }

  @override
  Widget buildLoader(BuildContext context) => const Text('loading');

  @override
  Future<String> query(QueryHooks use) async {
    queryCalls++;
    return queryVersion;
  }

  @override
  String get logTag => '_HotReloadQueryComponent';
}
