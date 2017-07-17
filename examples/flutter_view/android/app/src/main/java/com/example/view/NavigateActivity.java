package com.example.view;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

public class NavigateActivity extends FlutterActivity {

  private static final String CHANNEL = "samples.flutter.io/view";
  private static final String METHOD_SHOW_SPLIT_VIEW = "showSplitView";
  private static final String METHOD_SHOW_FULL_VIEW = "showFullView";


  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        new MethodChannel.MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
            if (methodCall.method.equals(METHOD_SHOW_SPLIT_VIEW)) {
              onlaunchSplitScreen();
            } else if (methodCall.method.equals(METHOD_SHOW_FULL_VIEW)) {
              onlaunchFullScreen();
            } else {
              result.notImplemented();
            }
          }
        }
    );
  }

  private void onlaunchFullScreen() {
    startActivity(new Intent(this, FullScreenFlutterActivity.class));
  }

  private void onlaunchSplitScreen() {
    startActivity(new Intent(this, SplitScreenActivity.class));
  }

}