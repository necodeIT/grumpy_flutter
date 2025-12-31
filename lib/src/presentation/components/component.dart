import 'package:flutter/widgets.dart';

/// A base class for all components in the application.
///
/// A Component represents a reusable UI element that can be composed
/// within screens or other components.
abstract class Component extends Widget {
  /// Creates a [Component] with an optional [key].
  const Component({super.key});
}
