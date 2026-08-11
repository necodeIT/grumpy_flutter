import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:grumpy_annotations/grumpy_annotations.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';
import 'package:logging/logging.dart';

/// Provides a set of hooks for querying data within a [QueryComponent].
class QueryHooks extends UseHooks {
  /// Provides a set of hooks for querying data within a [QueryComponent].
  const QueryHooks({
    required super.repo,
    required super.externalStream,
    required super.payloadStream,
  });

  /// Creates a [QueryHooks] instance from a [UseHooks] instance by passing through the relevant functions.
  factory QueryHooks.fromUseHooks(UseHooks useRepo) {
    return QueryHooks(
      repo: useRepo.repo,
      externalStream: useRepo.externalStream,
      payloadStream: useRepo.payloadStream,
    );
  }

  /// A hook that allows you to watch a [TextEditingController] and get its current text value reactively.
  ///
  /// [QueryComponent.query] will be re-executed whenever the text in the controller changes, allowing you to build reactive queries based on user input.
  String text(TextEditingController controller) => externalStream(
    controller,
    changeSignal: controller.stream,
    syncSnapshot: () => controller.text,
  );

  /// A hook that allows you to watch any [ValueListenable] and get its current value reactively.
  ///
  /// [QueryComponent.query] will be re-executed whenever the value changes, allowing you to build reactive queries based on any listenable value.
  T value<T>(ValueListenable<T> listenable) => externalStream(
    listenable,
    changeSignal: listenable.stream,
    syncSnapshot: () => listenable.value,
  );
}

/// A base class for components that perform data queries.
///
/// A [QueryComponent] is a [StatefulComponent] that executes a query to fetch
/// data of type [T] and builds its UI based on the query's state (loading,
/// error, or data).
/// It leverages [QueryHooks] to access repositories reactively.
abstract class QueryComponent<T> extends StatefulComponent with LogMixin {
  /// Creates a [QueryComponent] with an optional [key].
  const QueryComponent({super.key});

  /// Executes a query and returns the result of type [T].
  ///
  /// It is crucial that the implementation of this method uses the provided [use]
  /// hook instead of [Repo.get] to access repositories, or else the component will not
  /// be reactive to changes in the repositories' states.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// Future<List<User>> query(QueryHooks use) async {
  ///   final (users, usersRepo) = await use.repo<List<User>, UsersRepo>();
  ///   return await usersRepo.fetchUsers();
  /// }
  /// ```
  Future<T> query(QueryHooks use);

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

/// The successful value retained by a query component between rebuilds.
final class _QueryData<T> {
  /// Creates a successful query state for [data].
  const _QueryData(this.data);

  /// The latest value returned by [QueryComponent.query].
  final T data;
}

/// The failure retained by a query component between rebuilds.
final class _QueryError {
  /// Creates a failed query state with its optional [stackTrace].
  const _QueryError(this.error, this.stackTrace);

  /// The error thrown while resolving the query.
  final Object error;

  /// The stack trace associated with [error], when available.
  final StackTrace? stackTrace;
}

/// The loading state retained by a query component between rebuilds.
enum _QueryLoading {
  /// Indicates that the query is waiting for its dependencies or result.
  waiting,
}

class _QueryComponentState<T> extends State<QueryComponent<T>>
    with
        LifecycleMixin,
        LogMixin,
        LifecycleHooksMixin,
        UseRepoMixin<_QueryData<T>, _QueryError, _QueryLoading> {
  @initializer
  @override
  void initState() {
    log('Initializing QueryComponent state');
    super.initState();

    installUseRepoHooks();

    initialize();
  }

  @override
  void log(Object message, [Object? error, StackTrace? stackTrace]) {
    widget.log(message, error, stackTrace);
  }

  @override
  void logAtLevel(
    Level level,
    Object message, [
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
        return widget.buildContent(context, data.data);
      },
      error: (error) {
        log('Rendering error state');
        return widget.buildError(context, error.error, error.stackTrace);
      },
      loading: (loading) {
        log('Rendering loading state');
        return widget.buildLoader(context);
      },
    );
  }

  @override
  _QueryLoading onDependenciesLoading() => _QueryLoading.waiting;

  @override
  FutureOr<_QueryData<T>> onDependenciesReady(use) async {
    final data = await widget.query(QueryHooks.fromUseHooks(use));
    return _QueryData(data);
  }

  @override
  FutureOr<void> dependenciesChanged() {
    log('QueryComponent detected dependency change, rebuilding UI...');
    if (mounted) setState(() {});
  }

  @override
  FutureOr<_QueryError> onDependencyError(
    Object error,
    StackTrace? stackTrace,
  ) => _QueryError(error, stackTrace);

  @override
  void reassemble() {
    super.reassemble();
    unawaited(refreshDependencies());
  }

  @override
  void dispose() {
    destroy();
    super.dispose();
  }

  @override
  String get logTag => '_QueryComponentState';
}
