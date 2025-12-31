import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:grumpy/grumpy.dart' hide Builder;
import 'package:grumpy_flutter/grumpy_flutter.dart' hide Builder;

/// A base class for all screens in the application.
///
/// A Screen is a leaf node in the module tree that represents a distinct
/// UI screen or page.
abstract class Screen implements Leaf<Widget> {
  /// A base class for all screens in the application.
  ///
  /// A Screen is a leaf node in the module tree that represents a distinct
  /// UI screen or page.
  const Screen();

  /// Builds the main content of the screen.
  Widget buildContent(BuildContext context, RouteContext route);

  /// Builds a preview representation of the screen.
  Widget buildPreview(BuildContext context, RouteContext route);

  @override
  @nonVirtual
  FutureOr<Widget> content(RouteContext context) {
    return Builder(
      builder: (BuildContext ctx) {
        return buildContent(ctx, context);
      },
    );
  }

  @override
  @nonVirtual
  Widget preview(RouteContext context) {
    return Builder(
      builder: (BuildContext ctx) {
        return buildPreview(ctx, context);
      },
    );
  }
}
