import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef Watch<Value, T> = T Function(Value);
typedef Apply<T> = void Function(T);
typedef Accept = void Function<Value, T>(
    {required Watch<Value, T> watch, required Apply<T> apply});
typedef ShouldApply<Value> = bool Function(Value);

abstract class AcceptableStatefulWidget extends StatefulWidget {
  const AcceptableStatefulWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() => _AcceptableStatefulElement(this);
}

abstract class AcceptableStatefulWidgetState<T extends AcceptableStatefulWidget>
    extends State<T> {
  void acceptProviders(Accept accept);
}

class _AcceptableStatefulElement extends StatefulElement {
  _AcceptableStatefulElement(StatefulWidget widget) : super(widget);

  final _applyLogics = <_ApplyLogic>[];
  var _isFirstBuild = true;

  @override
  Widget build() {
    // As watching Provider is allowed only in build(),
    // it is done here only at the first time.
    if (_isFirstBuild) {
      _isFirstBuild = false;
      assert(state is AcceptableStatefulWidgetState);

      final acceptableState = state as AcceptableStatefulWidgetState;
      acceptableState.acceptProviders(<Value, T>({
        required watch,
        required apply,
      }) {
        final original = watch(Provider.of<Value>(this));
        final shouldApply = (Value newValue) {
          return !const DeepCollectionEquality()
              .equals(watch(newValue), original);
        };

        _applyLogics.add(
          _ApplyLogic<Value, T>(apply, watch, shouldApply)..applyValue(this),
        );
      });
    }

    return super.build();
  }

  @override
  void didChangeDependencies() {
    for (final applyLogic in _applyLogics) {
      if (applyLogic.callShouldApply(this)) {
        applyLogic.applyValue(this);
      }
    }
    super.didChangeDependencies();
  }
}

class _ApplyLogic<Value, T> {
  /// Function for apply given data to UI
  final Apply<T> apply;

  /// Function for select what data of Value to watch.
  final Watch<Value, T> watch;

  /// Function to determin if watching data is changed or not.
  ShouldApply<Value> shouldApply;

  _ApplyLogic(this.apply, this.watch, this.shouldApply);

  bool callShouldApply(BuildContext context) => shouldApply(_read(context));
  void applyValue(BuildContext context) => apply(watch(_read(context)));
  Value _read(BuildContext context) => context.read<Value>();
}
