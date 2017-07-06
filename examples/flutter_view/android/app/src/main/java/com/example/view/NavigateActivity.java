package com.example.view;

import android.content.Intent;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class NavigateActivity extends FlutterActivity {

  private static final String CHANNEL = "samples.flutter.io/platform_view";
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
    startActivity(new Intent(this, FullScreenActivity.class));
  }


  private void onlaunchSplitScreen() {
    Intent splitScreenIntent = new Intent(this, MainActivity.class);

    startActivity(splitScreenIntent);
  }


}