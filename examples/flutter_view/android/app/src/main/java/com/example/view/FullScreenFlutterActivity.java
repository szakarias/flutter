// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
package com.example.view;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager.LayoutParams;


import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

public class FullScreenFlutterActivity extends FlutterActivity {
  private static final String CHANNEL = "samples.flutter.io/platform_view";
  private static final String METHOD_SWITCH_VIEW = "switchView";
  private static final int COUNT_REQUEST = 1;

  private MethodChannel.Result result;

  @Override
  public FlutterView createFlutterView(Context context) {
    final FlutterView view = new FlutterView(this);
    view.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
    setContentView(view);
    view.setInitialRoute("/fullScreenView");
    return view;
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        new MethodChannel.MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
            FullScreenFlutterActivity.this.result = result;
            int count = methodCall.arguments();
            if (methodCall.method.equals(METHOD_SWITCH_VIEW)) {
              onlaunchFullScreen(count);
            } else {
              result.notImplemented();
            }
          }
        }
    );
  }

  private void onlaunchFullScreen(int count) {
    Intent fullScreenIntent = new Intent(this, FullScreenAndroidActivity.class);
    fullScreenIntent.putExtra(FullScreenAndroidActivity.EXTRA_COUNTER, count);
    startActivityForResult(fullScreenIntent, COUNT_REQUEST);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == COUNT_REQUEST) {
      if (resultCode == RESULT_OK) {
        result.success(data.getIntExtra(FullScreenAndroidActivity.EXTRA_COUNTER, 0));
      } else {
        result.error("ACTIVITY_FAILURE", "Failed while launching activity", null);
      }
    }
  }
}