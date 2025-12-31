import 'package:flutter/widgets.dart' hide Route;
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';
import 'package:grumpy/grumpy.dart' as grumpy;

/// Represents a Flutter-specific [Route] in the application.
///
/// Provides integration with the `go_router` package for navigation.
abstract class FlutterRoute<AppConfig extends Object>
    extends grumpy.Route<Widget, AppConfig> {
  /// Represents a Flutter-specific [Route] in the application.
  ///
  /// Provides integration with the `go_router` package for navigation.
  const FlutterRoute({required super.path});

  /// Converts this route into a GoRouter [RouteBase].
  RouteBase get goRoute;
}

/// A route that displays a [Screen] in the application.
class ScreenRoute<AppConfig extends Object>
    extends grumpy.LeafRoute<Widget, AppConfig>
    implements FlutterRoute<AppConfig> {
  @override
  Screen get view => super.view as Screen;

  @override
  List<FlutterRoute<AppConfig>> get children =>
      super.children.cast<FlutterRoute<AppConfig>>();

  /// A route that displays a [Screen] in the application.
  ScreenRoute({
    required super.path,
    required super.view,
    super.middleware,
    super.children = const [],
  }) : assert(view is Screen, 'view must be a Screen'),
       assert(
         children.isEmpty || children is List<FlutterRoute<AppConfig>>,
         'children must be FlutterRoutes',
       );

  @override
  RouteBase get goRoute => GoRoute(
    path: path,
    builder: (context, state) => ScreenRenderer(uri: state.uri),
    routes: children.map((child) => child.goRoute).toList(),
  );

  /// A root screen route.
  ///
  /// Used for defining the root of a module in a [ModuleRoute].
  ScreenRoute.root({required super.view, super.middleware, super.children})
    : assert(view is Screen, 'view must be a Screen'),
      assert(
        children.isEmpty || children is List<FlutterRoute<AppConfig>>,
        'children must be FlutterRoutes',
      ),
      super(path: '/');
}

/// A route that renders a shell around its child routes.
class ShellScreenRoute<AppConfig extends Object>
    extends Route<Widget, AppConfig>
    implements FlutterRoute<AppConfig> {
  /// Builds the shell widget.
  final ShellRouteBuilder shellBuilder;

  @override
  List<FlutterRoute<AppConfig>> get children =>
      super.children.cast<FlutterRoute<AppConfig>>();

  /// A route that renders a shell around its child routes.
  const ShellScreenRoute({
    required this.shellBuilder,
    super.middleware,
    super.children,
  }) : super(path: '');

  @override
  RouteBase get goRoute => ShellRoute(
    builder: shellBuilder,
    routes: children.map((child) => child.goRoute).toList(),
  );
}

/// A route that activates a [Module] when matched.
///
/// Use [ModuleRoute] for feature- or domain-level entry points that should
/// mount a dedicated [Module] (and its dependency graph) on navigation.
class ModuleRoute<AppConfig extends Object>
    extends grumpy.ModuleRoute<Widget, AppConfig>
    implements FlutterRoute<AppConfig> {
  @override
  List<FlutterRoute<AppConfig>> get children =>
      super.children.cast<FlutterRoute<AppConfig>>();

  @override
  grumpy.LeafRoute<Widget, AppConfig>? get root =>
      super.root ??
      ScreenRoute.root(view: GetIt.I<AppModule<AppConfig>>().notFoundScreen);

  @override
  Module<AppConfig> get module => super.module as Module<AppConfig>;

  /// A route that activates a [Module] when matched.
  ///
  /// Use [ModuleRoute] for feature- or domain-level entry points that should
  /// mount a dedicated [Module] (and its dependency graph) on navigation.
  ModuleRoute({
    required super.path,
    required super.module,
    super.middleware,
    super.root,
  }) : assert(
         root == null || root is ScreenRoute<AppConfig>,
         'root must be a ScreenRoute',
       ),
       assert(
         module is Module<AppConfig>,
         'module must be a Module<AppConfig>',
       );

  @override
  RouteBase get goRoute {
    return GoRoute(
      path: path,

      builder: (context, state) {
        return ScreenRenderer(uri: state.uri);
      },

      routes: module.routes.map((child) => child.goRoute).toList(),
    );
  }
}
