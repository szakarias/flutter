// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_view/platform_back_button.dart';

class SplitScreenView extends StatefulWidget {
  const SplitScreenView(this.title);

  final String title;
  @override
  _SplitScreenViewState createState() => new _SplitScreenViewState();
}

class _SplitScreenViewState extends State<SplitScreenView> {
  static const BasicMessageChannel<String> _platform =
      const BasicMessageChannel<String>(
          'samples.flutter.io/increment', const StringCodec());
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
    return new Scaffold(
      appBar: new AppBar(
        leading: new PlatformBackButton(),
        title: new Text(widget.title),
      ),
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
