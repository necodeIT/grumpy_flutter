import 'package:flutter/widgets.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';

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
    extends State<ScreenRenderer<AppConfig>> {
  final router = Service.get<RoutingService<Widget, AppConfig>>();

  @override
  void initState() {
    super.initState();
    router.navigate(
      widget.uri.toString(),
      callback: (screen) {
        if (!mounted) return;
        setState(() {
          child = screen;
        });
      },
    );
  }

  Widget? child;

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}
