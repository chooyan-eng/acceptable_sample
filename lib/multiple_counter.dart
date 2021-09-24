import 'package:custom_stateful_widget_practice/acceptable_stateful_widget.dart';
import 'package:custom_stateful_widget_practice/main.dart';
import 'package:flutter/material.dart';

class MultipleCounter extends AcceptableStatefulWidget {
  const MultipleCounter({Key? key}) : super(key: key);

  @override
  _MultipleCounterState createState() => _MultipleCounterState();
}

class _MultipleCounterState
    extends AcceptableStatefulWidgetState<MultipleCounter> {
  late int _value;

  @override
  void acceptProviders(Accept accept) {
    accept<CounterState, int>(
      watch: (state) => state.value,
      apply: (value) => _value = value * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Twice'),
        Text(
          '$_value',
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}
