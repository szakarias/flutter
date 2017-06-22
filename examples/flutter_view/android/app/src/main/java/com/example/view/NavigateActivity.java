package com.example.view;

import android.content.Intent;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class NavigateActivity extends FlutterActivity {

  private static final String CHANNEL = "samples.flutter.io/platform_view";
  private static final String METHOD_SWITCH_VIEW = "switchView";

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        new MethodChannel.MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
            if (methodCall.method.equals(METHOD_SWITCH_VIEW)) {
              onlaunchSplitScreen();
            } else {
              result.notImplemented();
            }
          }
        }
    );
  }

  private void onlaunchSplitScreen() {
    Intent splitScreenIntent = new Intent(this, MainActivity.class);

    startActivity(splitScreenIntent);
  }


}