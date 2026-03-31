import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:grumpy_annotations/grumpy_annotations.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';
import 'package:logging/logging.dart';

/// Provides a set of hooks for querying data within a [QueryComponent].
class QueryHooks extends UseHooks {
  /// Provides a set of hooks for querying data within a [QueryComponent].
  const QueryHooks({required super.repo, required super.externalStream});

  /// Creates a [QueryHooks] instance from a [UseHooks] instance by passing through the relevant functions.
  factory QueryHooks.fromUseHooks(UseHooks useRepo) {
    return QueryHooks(
      repo: useRepo.repo,
      externalStream: useRepo.externalStream,
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

class _QueryComponentState<T> extends State<QueryComponent<T>>
    with
        LifecycleMixin,
        LogMixin,
        LifecycleHooksMixin,
        UseRepoMixin<Widget, Widget, Widget> {
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
  FutureOr<Widget> onDependenciesReady(use) async {
    final data = await widget.query(QueryHooks.fromUseHooks(use));

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
    destroy();
    super.dispose();
  }

  @override
  String get logTag => '_QueryComponentState';
}
