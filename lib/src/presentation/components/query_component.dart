import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:grumpy_annotations/grumpy_annotations.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';
import 'package:logging/logging.dart';

/// A function type that defines a hook for using repositories.
typedef ReadRepo = Future<(S, R)> Function<S, R extends Repo<S>>();

/// A base class for components that perform data queries.
///
/// A [QueryComponent] is a [StatefulComponent] that executes a query to fetch
/// data of type [T] and builds its UI based on the query's state (loading,
/// error, or data).
/// It leverages the [ReadRepo] hook to access repositories reactively.
abstract class QueryComponent<T> extends StatefulComponent with LogMixin {
  /// Creates a [QueryComponent] with an optional [key].
  const QueryComponent({super.key});

  /// Executes a query and returns the result of type [T].
  ///
  /// It is crucial that the implementation of this method uses the provided [use]
  /// hook instead of [Repo.get] to access repositories, or else the component will not
  /// be reactive to changes in the repositories' states.
  Future<T> query(ReadRepo use);

  /// Builds the loader widget to display while the query is loading.
  Widget buildLoader(BuildContext context);

  /// Builds the error widget to display if the query fails.
  Widget buildError(BuildContext context, Object error, StackTrace? stackTrace);

  /// Builds the content widget to display when the query succeeds.
  Widget buildContent(BuildContext context, T data);

  @override
  @nonVirtual
  State<QueryComponent<T>> createState() => _QueryComponentState<T>();
  @override
  String get group => 'QueryComponent';

  @override
  Level get logLevel => Level.FINEST;
}

class _QueryComponentState<T> extends State<QueryComponent<T>>
    with
        LifecycleMixin,
        LogMixin,
        LifecycleHooksMixin,
        UseRepoMixin<Widget, Widget, Widget> {
  @initializer
  @override
  void initState() async {
    super.initState();

    installUseRepoHooks();

    initialize();
  }

  @override
  void log(String message, [Object? error, StackTrace? stackTrace]) {
    widget.log(message, error, stackTrace);
  }

  @override
  void logAtLevel(
    Level level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    // this is a pass-through to [QueryComponent].
    // ignore: invalid_use_of_internal_member
    widget.logAtLevel(level, message, error, stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    return when(
      data: (data) {
        log('Rendering data state');
        return data;
      },
      error: (error) {
        log('Rendering error state');
        return error;
      },
      loading: (loading) {
        log('Rendering loading state');
        return loading;
      },
    );
  }

  @override
  Widget onDependenciesLoading() {
    return widget.buildLoader(context);
  }

  @override
  FutureOr<Widget> onDependenciesReady() async {
    final data = await widget.query(useRepo);

    if (!mounted) return const SizedBox.shrink();

    return widget.buildContent(context, data);
  }

  @override
  FutureOr<void> dependenciesChanged() {
    log('QueryComponent detected dependency change, rebuilding UI...');
    setState(() {});
  }

  @override
  FutureOr<Widget> onDependencyError(Object error, StackTrace? stackTrace) {
    return widget.buildError(context, error, stackTrace);
  }

  @override
  void dispose() {
    free();
    super.dispose();
  }
}
