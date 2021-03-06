import 'package:custom_stateful_widget_practice/acceptable_stateful_widget.dart';
import 'package:custom_stateful_widget_practice/main.dart';
import 'package:flutter/material.dart';

class AppendUnitCounter extends AcceptableStatefulWidget {
  const AppendUnitCounter({Key? key}) : super(key: key);

  @override
  _AppendUnitCounterState createState() => _AppendUnitCounterState();
}

class _AppendUnitCounterState
    extends AcceptableStatefulWidgetState<AppendUnitCounter> {
  late String _value;

  @override
  void acceptProviders(Accept accept) {
    accept<CounterState, int>(
      watch: (state) => state.value,
      apply: (value) => _value = '$value HITS',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('with Unit'),
        Text(
          _value,
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}
