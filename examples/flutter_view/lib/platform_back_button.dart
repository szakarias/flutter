// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TODO(zarah): Remove this class and use BackButton once "pop" has been
/// refactored (issue  #11490).
class PlatformBackButton extends StatelessWidget {

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
        onPressed: () {
          Navigator.of(context).maybePop().then((bool didPop) {
            if (didPop)
              return;
            SystemNavigator.pop();
          }).catchError((dynamic error) {});
        },
    );
  }
}
