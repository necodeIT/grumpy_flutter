import 'dart:async';

import 'package:flutter/foundation.dart';

final _valueListenableStreams = Expando<_ValueListenableStreamCache>(
  'ValueListenable streams',
);

/// Extension on [ValueListenable] to provide a stream of value changes.
extension ValueListenableX<T> on ValueListenable<T> {
  /// Returns a stream that emits the current value whenever it changes.
  ///
  /// The stream is stable for the lifetime of this listenable and is broadcast,
  /// allowing multiple listeners to subscribe without creating duplicate
  /// [ValueListenable] listeners.
  ///
  /// It subscribes lazily when the first stream listener attaches and detaches
  /// when the last listener cancels.
  Stream<T> get stream {
    final cache = _valueListenableStreams[this] ??= _ValueListenableStreamCache(
      this,
    );
    return cache.stream<T>();
  }
}

final class _ValueListenableStreamCache {
  _ValueListenableStreamCache(this.listenable) {
    controller = StreamController<dynamic>.broadcast(
      sync: true,
      onListen: () => listenable.addListener(_emitValue),
      onCancel: () => listenable.removeListener(_emitValue),
    );
  }

  final ValueListenable<dynamic> listenable;
  late final StreamController<dynamic> controller;
  final _typedStreams = <Type, Stream<dynamic>>{};

  void _emitValue() => controller.add(listenable.value);

  Stream<T> stream<T>() {
    final cached = _typedStreams[T];
    if (cached != null) return cached as Stream<T>;

    final stream = controller.stream.cast<T>();
    _typedStreams[T] = stream;
    return stream;
  }
}
