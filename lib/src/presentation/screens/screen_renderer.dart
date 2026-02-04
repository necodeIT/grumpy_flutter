import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';
import 'package:logging/logging.dart';

/// A widget that renders the current screen by listening to [RoutingService.onViewChanged].
class ScreenRenderer<AppConfig extends Object> extends StatefulWidget {
  /// Creates a ScreenRenderer.
  const ScreenRenderer({super.key});

  @override
  State<ScreenRenderer> createState() => _ScreenRendererState<AppConfig>();
}

class _ScreenRendererState<AppConfig extends Object>
    extends State<ScreenRenderer<AppConfig>>
    with LogMixin {
  final router = Service.get<RoutingService<Widget, AppConfig>>();
  late final StreamSubscription<ViewChangedEvent<Widget, AppConfig>>
  _subscription;

  @override
  Level get logLevel => Level.FINEST;

  @override
  String get group => 'ScreenRenderer';

  @override
  void initState() {
    super.initState();

    _subscription = router.onViewChanged((event) {
      log(
        'Rendering ${event.isPreview ? 'preview' : 'final'} view for URI: ${event.context?.fullPath}',
      );

      if (mounted) {
        setState(() {
          child = event.view;
        });
      }
    });
  }

  Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      log(
        'No child widget to render for URI: ${router.currentContext?.fullPath}',
      );
    }
    return child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    super.dispose();

    log('Disposing ScreenRenderer for URI: ${router.currentContext?.fullPath}');

    _subscription.cancel();
  }

  @override
  String get logTag => '_ScreenRendererState';
}
