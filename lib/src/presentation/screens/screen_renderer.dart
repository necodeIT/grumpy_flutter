import 'package:flutter/widgets.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';
import 'package:logging/logging.dart';

/// A widget that renders a screen based on the provided URI.
class ScreenRenderer<AppConfig extends Object> extends StatefulWidget {
  /// The URI to render.
  final Uri uri;

  /// Creates a ScreenRenderer.
  const ScreenRenderer({super.key, required this.uri});

  @override
  State<ScreenRenderer> createState() => _ScreenRendererState<AppConfig>();
}

class _ScreenRendererState<AppConfig extends Object>
    extends State<ScreenRenderer<AppConfig>>
    with LogMixin {
  final router = Service.get<RoutingService<Widget, AppConfig>>();

  @override
  Level get logLevel => Level.FINEST;

  @override
  String get group => 'ScreenRenderer';

  @override
  void initState() {
    super.initState();
    router.navigate(
      widget.uri.toString(),
      callback: (screen, preview) {
        if (!mounted) return;
        log(
          'Rendering ${preview ? "preview" : "content"} for URI: ${widget.uri}',
        );
        setState(() {
          child = screen;
        });
      },
    );
  }

  Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) log('No child widget to render for URI: ${widget.uri}');
    return child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    super.dispose();

    log('Disposing ScreenRenderer for URI: ${widget.uri}');
  }
}
