// we're doing unit tests, so we can ignore this lint
// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';

import 'repos.dart';

class BaseStringQueryComponent extends QueryComponent<String> {
  final String label;

  const BaseStringQueryComponent({required this.label});

  @override
  Widget buildContent(BuildContext context, String data) {
    return Text('$label-content: $data');
  }

  @override
  Widget buildError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Text('$label-error: $error');
  }

  @override
  Widget buildLoader(BuildContext context) {
    return Text('$label-loader');
  }

  @override
  Future<String> query(ReadRepo use) async {
    final (value, _) = await use<String, TestRepo>();
    return value;
  }
}

class StatefulContentQueryComponent extends BaseStringQueryComponent
    with StatefulQueryContent<String> {
  const StatefulContentQueryComponent({required super.label});

  @override
  QueryComponentContentState<String> createContentState() => _ContentState();
}

class _ContentState extends State<StatefulQueryContentComponent<String>> {
  int taps = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('stateful-content: ${widget.data}'),
        Text('content taps: $taps'),
        TextButton(
          onPressed: () => setState(() => taps++),
          child: const Text('toggle content'),
        ),
      ],
    );
  }
}

class DynamicQueryComponent extends QueryComponent<dynamic> {
  final String label;

  const DynamicQueryComponent({required this.label});

  @override
  Widget buildContent(BuildContext context, dynamic data) {
    return Text('$label-content: $data');
  }

  @override
  Widget buildError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Text('$label-error: $error');
  }

  @override
  Widget buildLoader(BuildContext context) {
    return Text('$label-loader');
  }

  @override
  Future<dynamic> query(ReadRepo use) async {
    final (value, _) = await use<String, TestRepo>();
    return value;
  }
}

class StatefulErrorQueryComponent extends DynamicQueryComponent
    with StatefulQueryError {
  const StatefulErrorQueryComponent({required super.label});

  @override
  QueryComponentErrorState createErrorState() => _ErrorState();
}

class _ErrorState extends State<StatefulQueryErrorComponent> {
  int taps = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('error-state: ${widget.error}'),
        Text('error taps: $taps'),
        TextButton(
          onPressed: () => setState(() => taps++),
          child: const Text('inspect error'),
        ),
      ],
    );
  }
}

class StatefulLoaderQueryComponent extends DynamicQueryComponent
    with StatefulQueryLoader {
  const StatefulLoaderQueryComponent({required super.label});

  @override
  QueryComponentLoaderState createLoaderState() => _LoaderState();
}

class _LoaderState extends State<StatefulQueryLoaderComponent> {
  int taps = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('loader-loading taps: $taps'),
        TextButton(
          onPressed: () => setState(() => taps++),
          child: const Text('nudge loader'),
        ),
      ],
    );
  }
}
