import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(new FlutterView());
}

class FlutterView extends StatelessWidget {
  static const MethodChannel _methodChannel =
      const MethodChannel("samples.flutter.io/platform_view");

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter View',
      theme: new ThemeData(
        primarySwatch: Colors.grey,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new Scaffold(
              appBar: new AppBar(title: new Text('Flutter View')),
              body: new Center(
                child: new RaisedButton(
                  onPressed: showSplitView,
                  child: new Text('Show split view'),
                ),
              ),
            ),
        '/splitView':(BuildContext context) => new MyHomePage()
      },
      // Forces use of initial route from platform (otherwise it defaults to /
      // and platform's initial route is ignored).
      initialRoute: window.defaultRouteName,
    );
  }

  void showSplitView() {
    // Tell Android to load splitview layout
    _methodChannel.invokeMethod("switchView");
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _channel = "increment";
  static const String _pong = "pong";
  static const String _emptyMessage = "";
  static const BasicMessageChannel<String> platform =
      const BasicMessageChannel<String>(_channel, const StringCodec());

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    platform.setMessageHandler(_handlePlatformIncrement);
  }

  Future<String> _handlePlatformIncrement(String message) async {
    setState(() {
      _counter++;
    });
    return _emptyMessage;
  }

  void _sendFlutterIncrement() {
    platform.send(_pong);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Flutter View')),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
            child: new Center(
                child: new Text(
                    'Platform button tapped $_counter time${ _counter == 1 ? '' : 's' }.',
                    style: const TextStyle(fontSize: 17.0))),
          ),
          new Container(
            padding: const EdgeInsets.only(bottom: 15.0, left: 5.0),
            child: new Row(
              children: <Widget>[
                new Image.asset('assets/flutter-mark-square-64.png',
                    scale: 1.5),
                const Text('Flutter', style: const TextStyle(fontSize: 30.0)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _sendFlutterIncrement,
        child: const Icon(Icons.add),
      ),
    );
  }
}
