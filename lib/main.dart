import 'package:custom_stateful_widget_practice/custom_stateful_widget.dart';
import 'package:custom_stateful_widget_practice/multiple_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class CounterState extends ValueNotifier<int> {
  CounterState(int value) : super(value);

  void add() => value += 1;
  void clear() => value = 0;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        child: MyHomePage(title: 'Flutter Demo Home Page'),
        create: (context) => CounterState(0),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            const MultipleCounter(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: context.read<CounterState>().add,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
