import 'package:grumpy_flutter/grumpy_flutter.dart';

/// Error thrown when [Guard.redirectTo] is not specified in a [Guard].
class RouteNotAuthorizedError extends Error {
  /// The route context that was not authorized.
  final RouteContext context;

  /// Creates a [RouteNotAuthorizedError] with the given [context].
  RouteNotAuthorizedError(this.context);

  @override
  String toString() {
    return 'RouteNotAuthorizedError: Access to route ${context.fullPath} is not authorized.';
  }
}
