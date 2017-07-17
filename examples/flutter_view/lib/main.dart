// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_view/full_screen_view.dart';
import 'package:flutter_view/split_screen_view.dart';

void main() {
  print('Running main ${window.defaultRouteName}');
  runApp(new FlutterView());
}

const MethodChannel _methodChannel =
    const MethodChannel("samples.flutter.io/view");
const String title = 'Flutter View';
const String _showSplitViewMethod = 'showSplitView';
const String _showFullViewMethod = 'showFullView';

class FlutterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter View',
      theme: new ThemeData(
        primarySwatch: Colors.grey,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new MyHomePage(title),
        'splitView': (BuildContext context) => new SplitScreenView(title),
        'fullScreenView': (BuildContext context) => new FullScreenView(title),
      },
      // Forces use of initial route from platform (otherwise it defaults to /
      // and platform's initial route is ignored).
      initialRoute: window.defaultRouteName,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.title);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Center(
              child: new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new RaisedButton(
                  onPressed: () =>
                      _methodChannel.invokeMethod(_showSplitViewMethod),
                  child: new Text('Show split view'),
                ),
              ),
            ),
            new RaisedButton(
              onPressed: () => _methodChannel.invokeMethod(_showFullViewMethod),
              child: new Text('Show full screen view'),
            ),
          ],
        ),
      );
}
