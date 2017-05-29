import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  print("Running MAIN");
  runApp(new FlutterView());
}

class FlutterView extends StatelessWidget {
//  final Widget splitView = new MyHomePage();
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
              body: new ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: <Widget>[
                  new RaisedButton(onPressed: showSplitView)
//            new _Item(
//              title: 'Split View',
//              subtitle: 'Split view with Flutter and Platform UI',
//              target: showSplitView,
//            ),
                ],
              ),
            ),
        '/splitView': (BuildContext context) => new MyHomePage()
      },
    );

//
//    return new MaterialApp(
//      title: 'Flutter View',
//      theme: new ThemeData(
//        primarySwatch: Colors.grey,
//      ),
//      home: new MyHomePage(),
//    );
  }

  void showSplitView() {
    // Tell Android to load splitview layout
    print("Invoke switch view");
    _methodChannel.invokeMethod("switchView");
    //return new MyHomePage();
  }
}

class _Item extends StatelessWidget {
  _Item({Key key, this.title, this.subtitle, this.target}) : super(key: key);

  final String title;
  final String subtitle;
  final WidgetBuilder target;

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(title),
      subtitle: new Text(subtitle),
      onTap: (target != null)
          ? () {
              Navigator.push(
                  context, new MaterialPageRoute<dynamic>(builder: target));
            }
          : null,
    );
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
    print("Building MyHomePage");
    return new Scaffold(
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
