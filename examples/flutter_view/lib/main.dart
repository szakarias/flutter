import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  print('Running main ${window.defaultRouteName}');
  runApp(new FlutterView());
}

const appBarText = const Text('Flutter View');

class FlutterView extends StatelessWidget {
  static const MethodChannel _methodChannel =
      const MethodChannel("samples.flutter.io/platform_view");
  static const String _showSplitView = 'showSplitView';
  static const String _showFullView = 'showFullView';

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter View',
      theme: new ThemeData(
        primarySwatch: Colors.grey,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new Scaffold(
              appBar: new AppBar(title: appBarText),
              body: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: new RaisedButton(
                        onPressed: showSplitView,
                        child: new Text('Show split view'),
                      ),
                    ),
                  ),
                  new RaisedButton(
                    onPressed: showFullScreenView,
                    child: new Text('Show full screen view'),
                  ),
                ],
              ),
            ),
        '/splitView': (BuildContext context) => new SplitScreenView(),
        '/fullScreenView': (BuildContext context) => new FullScreenViewPage(),
      },
      // Forces use of initial route from platform (otherwise it defaults to /
      // and platform's initial route is ignored).
      initialRoute: window.defaultRouteName,
    );
  }

  void showSplitView() {
    _methodChannel.invokeMethod(_showSplitView);
  }

  void showFullScreenView() {
    _methodChannel.invokeMethod(_showFullView);
  }
}

class MyBackButton extends StatelessWidget {
  /// Creates an [IconButton] with the appropriate "back" icon for the current
  /// target platform.
  const MyBackButton({Key key, this.color, this.onPressed}) : super(key: key);

  /// The color to use for the icon.
  ///
  /// Defaults to the [IconThemeData.color] specified in the ambient [IconTheme],
  /// which usually matches the ambient [Theme]'s [ThemeData.iconTheme].
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    context;
    return new IconButton(
      icon: const BackButtonIcon(),
      color: color,
      tooltip: 'Back',
      onPressed: onPressed,
    );
  }
}

class FullScreenViewPage extends StatefulWidget {

  const FullScreenViewPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FullScreenViewPageState createState() => new _FullScreenViewPageState();
}

class _FullScreenViewPageState extends State<FullScreenViewPage> {
  static const MethodChannel _methodChannel =
  const MethodChannel("samples.flutter.io/platform_view");

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<Null> _launchPlatformCount() async {
    final int platformCounter =
    await _methodChannel.invokeMethod("switchView", _counter);
    setState(() {
      _counter = platformCounter;
    });
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
    appBar: new AppBar(
      title: appBarText,
    ),
    body: new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  'Button tapped $_counter time${ _counter == 1 ? '' : 's' }.',
                  style: const TextStyle(fontSize: 17.0),
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new RaisedButton(
                      child: Platform.isIOS
                          ? const Text('Continue in iOS view')
                          : const Text('CONTINUE IN ANDROID VIEW'),
                      onPressed: _launchPlatformCount),
                ),
              ],
            ),
          ),
        ),
        new Container(
          padding: const EdgeInsets.only(bottom: 16.0, left: 5.0),
          child: new Row(
            children: <Widget>[
              new Image.asset('assets/flutter-mark-square-64.png',
                  scale: 1.5),
              const Text(
                'Flutter',
                style: const TextStyle(fontSize: 30.0),
              ),
            ],
          ),
        ),
      ],
    ),
    floatingActionButton: new FloatingActionButton(
      onPressed: _incrementCounter,
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ),
  );
}

class SplitScreenView extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<SplitScreenView> {
  static const BasicMessageChannel<String> _platform =
      const BasicMessageChannel<String>(
          'samples.flutter.io/increment', const StringCodec());
  static const MethodChannel _methodBackChannel =
      const MethodChannel('samples.flutter.io/back');
  static const String _pong = "pong";
  static const String _emptyMessage = "";

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _platform.setMessageHandler(_handlePlatformIncrement);
  }

  Future<String> _handlePlatformIncrement(String message) async {
    setState(() {
      _counter++;
    });
    return _emptyMessage;
  }

  void _sendFlutterIncrement() {
    _platform.send(_pong);
  }

  @override
  Widget build(BuildContext context) {
    MyBackButton myBackButton = new MyBackButton(
      onPressed: () {
        _methodBackChannel.invokeMethod('backPressed');
        Navigator.of(context).maybePop();
      },
    );

    return new Scaffold(
      appBar: new AppBar(leading: myBackButton, title: appBarText),
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
