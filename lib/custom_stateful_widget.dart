import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AcceptableStatefulWidget extends StatefulWidget {
  const AcceptableStatefulWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() {
    return _AcceptableStatefulElement(this);
  }
}

typedef Watch<Value, T> = T Function(Value);
typedef Apply<T> = void Function(T);
typedef Accept = void Function<Value, T>(
    {required Watch<Value, T> watch, required Apply<T> apply});

abstract class AcceptableStatefulWidgetState<T extends AcceptableStatefulWidget>
    extends State<T> {
  void acceptProviders(Accept accept);
}

typedef ShouldConvert = bool Function();

class _AcceptableStatefulElement extends StatefulElement {
  _AcceptableStatefulElement(StatefulWidget widget) : super(widget);

  final _applyLogics = <ApplyLogic>[];
  var _isFirstBuild = true;

  @override
  Widget build() {
    if (_isFirstBuild) {
      _isFirstBuild = false;
      final acceptableState = state as AcceptableStatefulWidgetState;
      acceptableState.acceptProviders(<Value, T>({
        required watch,
        required apply,
      }) {
        final value = Provider.of<Value>(this, listen: false);
        final original = watch(value);
        final shouldConvert = () {
          final newValue = Provider.of<Value>(this, listen: false);
          return !const DeepCollectionEquality()
              .equals(watch(newValue), original);
        };

        _applyLogics.add(ApplyLogic<Value, T>(apply, watch, shouldConvert));
      });
    }

    for (final applyLogic in _applyLogics) {
      if (!applyLogic.isDepended) {
        applyLogic.dependOnProvider(this);
        applyLogic.isDepended = true;
      }
    }

    return super.build();
  }

  @override
  void didChangeDependencies() {
    for (final applyLogic in _applyLogics) {
      final newValue = applyLogic.watchValue(this);
      if (applyLogic.shouldConvert()) {
        applyLogic.applyValue(newValue);
      }
    }
    super.didChangeDependencies();
  }
}

class ApplyLogic<Value, T> {
  final Apply<T> apply;
  final Watch<Value, T> watch;
  ShouldConvert shouldConvert;
  bool isDepended = false;

  ApplyLogic(this.apply, this.watch, this.shouldConvert);

  void dependOnProvider(BuildContext context) => Provider.of<Value>(context);
  Value read(BuildContext context) =>
      Provider.of<Value>(context, listen: false);

  T watchValue(BuildContext context) {
    final newValue = Provider.of<Value>(context, listen: false);
    return watch(newValue);
  }

  void applyValue(dynamic value) => apply(value as T);
}
