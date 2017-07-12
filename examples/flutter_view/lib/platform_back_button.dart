// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformBackButton extends StatelessWidget {
  /// Creates an [IconButton] with the appropriate "back" icon for the current
  /// target platform. [onPressed] instructs the [Navigator] widget to should
  /// pop its current route if possible. If not, the system navigator is
  /// instructed to remove this activity from the stack and
  /// return to the previous activity.
  ///
  const PlatformBackButton({Key key, this.color}) : super(key: key);

  /// The color to use for the icon.
  ///
  /// Defaults to the [IconThemeData.color] specified in the ambient [IconTheme],
  /// which usually matches the ambient [Theme]'s [ThemeData.iconTheme].
  final Color color;

  @override
  Widget build(BuildContext context) {
    context;
    return new IconButton(
      icon: const BackButtonIcon(),
      color: color,
      tooltip: 'Back',
      onPressed: () async {
        print("PlatformBackButton pressed");
        if (await Navigator.of(context).maybePop()) {
          print("maybe pop true");
          return;
        }
        SystemNavigator.pop();
      },
    );
  }
}
