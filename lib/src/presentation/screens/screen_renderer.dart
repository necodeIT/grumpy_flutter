import 'package:flutter/widgets.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';
import 'package:logging/logging.dart';

/// A widget that renders the current screen by listening to [RoutingService.onViewChanged].
class ScreenRenderer<AppConfig extends Object> extends StatefulWidget {
  /// Creates a ScreenRenderer.
  const ScreenRenderer({super.key, required this.uri});

  /// The URI to navigate to and render.
  final Uri uri;

  @override
  State<ScreenRenderer> createState() => _ScreenRendererState<AppConfig>();
}

class _ScreenRendererState<AppConfig extends Object>
    extends State<ScreenRenderer<AppConfig>>
    with LogMixin {
  final router = RoutingService<Widget, AppConfig>();

  bool navigated = false;

  void navigate() {
    if (navigated) return;

    log('Navigating to: ${widget.uri}');

    try {
      router.navigate(widget.uri.toString(), callback: renderView);
    } catch (e, s) {
      log('Navigation to ${widget.uri} failed', e, s);
    } finally {
      navigated = true;
    }
  }

  void renderView(Widget view, bool isPreview) {
    if (!mounted) {
      log('ScreenRenderer is not mounted, cannot render view.');
      return;
    }

    log(
      'Rendering ${isPreview ? 'preview' : 'final'} view for URI: ${widget.uri}',
    );

    setState(() {
      _currentView = view;
    });
  }

  Widget? _currentView;

  @override
  void initState() {
    super.initState();
    navigate();
  }

  @override
  Level get logLevel => Level.FINEST;

  @override
  String get group => 'ScreenRenderer';

  @override
  Widget build(BuildContext context) {
    if (_currentView == null) {
      log('No view to render yet for URI: ${widget.uri}. Showing placeholder.');
    }

    return _currentView ?? const SizedBox.shrink();
  }

  @override
  String get logTag => '_ScreenRendererState';
}
