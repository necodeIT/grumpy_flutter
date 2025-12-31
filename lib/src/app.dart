import 'package:flutter/widgets.dart' hide Route;
import 'package:go_router/go_router.dart';
import 'package:grumpy/grumpy.dart' as grumpy;
import 'package:grumpy_flutter/grumpy_flutter.dart';

export 'domain/domain.dart';
export 'presentation/presentation.dart';
export 'package:grumpy/grumpy.dart'
    hide RootModule, LeafRoute, Leaf, ModuleRoute, Module;

/// The root module of a Flutter application.
abstract class AppModule<AppConfig extends Object>
    extends grumpy.RootModule<Widget, AppConfig> {
  /// The root module of a Flutter application.
  AppModule(super.cfg);

  GoRouter? _goRouter;

  /// The screen to display for unknown routes (404).
  Screen get notFoundScreen;

  /// The initial location to navigate to on app start.
  String get initialLocation => '/';

  /// The path for the not found (404) screen.
  static const String notFoundPath = '/404';

  @override
  @mustCallSuper
  void bindExternalDeps(grumpy.Bind<Object, AppConfig> bind) {
    bind<AppModule<AppConfig>>((_, _) => this);
  }

  @override
  List<FlutterRoute<AppConfig>> get routes => [];

  @override
  // we want to redefine root here to add the 404 route
  // ignore: invalid_use_of_internal_member
  Route<Widget, AppConfig> get root => Route.root([
    ScreenRoute(path: notFoundPath, view: notFoundScreen),
    ...routes,
  ]);

  /// The GoRouter instance for the application.
  GoRouter get goRouter {
    return _goRouter ??= GoRouter(
      debugLogDiagnostics: true,
      initialLocation: initialLocation,
      routes: _createGoRoutes(),
    );
  }

  List<RouteBase> _createGoRoutes() {
    final root = this.root;

    final routes = <RouteBase>[];

    for (final child in root.children) {
      if (child is! FlutterRoute<AppConfig>) {
        throw StateError('All routes in AppModule must be FlutterRoutes');
      }

      routes.add(child.goRoute);
    }

    return routes;
  }
}

/// A modular unit of functionality within an application
/// encapsulating routes and dependencies.
///
/// Use this to define your App's features.
abstract class Module<AppConfig extends Object>
    extends grumpy.Module<Widget, AppConfig> {
  @override
  List<FlutterRoute<AppConfig>> get routes => [];
}
