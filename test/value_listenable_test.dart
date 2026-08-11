import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';

void main() {
  test('returns one stable broadcast stream per ValueListenable', () {
    final listenable = ValueNotifier<int>(0);
    addTearDown(listenable.dispose);

    expect(identical(listenable.stream, listenable.stream), isTrue);
    expect(listenable.stream.isBroadcast, isTrue);
  });

  test('shares one listener across compatible static value types', () async {
    final listenable = _CountingValueNotifier<int>(0);
    final ValueListenable<Object?> widened = listenable;
    addTearDown(listenable.dispose);

    final narrowValues = <int>[];
    final wideValues = <Object?>[];
    final narrow = listenable.stream.listen(narrowValues.add);
    final wide = widened.stream.listen(wideValues.add);

    expect(listenable.activeListeners, 1);

    listenable.value = 1;
    expect(narrowValues, [1]);
    expect(wideValues, [1]);

    await narrow.cancel();
    await wide.cancel();
    expect(listenable.activeListeners, 0);
  });

  test('shares and removes the underlying ValueListenable listener', () async {
    final listenable = _CountingValueNotifier<int>(0);
    addTearDown(listenable.dispose);

    final firstValues = <int>[];
    final secondValues = <int>[];
    final first = listenable.stream.listen(firstValues.add);
    final second = listenable.stream.listen(secondValues.add);

    expect(listenable.activeListeners, 1);

    listenable.value = 1;
    expect(firstValues, [1]);
    expect(secondValues, [1]);

    await first.cancel();
    expect(listenable.activeListeners, 1);

    await second.cancel();
    expect(listenable.activeListeners, 0);
  });
}

class _CountingValueNotifier<T> extends ValueNotifier<T> {
  _CountingValueNotifier(super.value);

  int activeListeners = 0;

  @override
  void addListener(VoidCallback listener) {
    activeListeners++;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    activeListeners--;
    super.removeListener(listener);
  }
}
