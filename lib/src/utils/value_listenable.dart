import 'dart:async';

import 'package:flutter/foundation.dart';

/// Extension on [ValueListenable] to provide a stream of value changes.
extension ValueListenableX<T> on ValueListenable<T> {
  /// Returns a stream that emits the current value whenever it changes.
  ///
  /// The stream is a broadcast stream, allowing multiple listeners to subscribe
  /// to value changes without interfering with each other.
  Stream<T> get stream {
    final controller = StreamController<T>();
    void listener() => controller.add(value);

    addListener(listener);
    controller.onCancel = () => removeListener(listener);

    return controller.stream.asBroadcastStream();
  }
}
