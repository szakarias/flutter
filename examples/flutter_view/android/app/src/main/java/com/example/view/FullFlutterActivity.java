package com.example.view;

import android.content.Intent;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;

import java.util.ArrayList;

import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterView;

public class FullFlutterActivity extends AppCompatActivity {

    private FlutterView flutterView;
    private String[] getArgsFromIntent(Intent intent) {
        // Before adding more entries to this list, consider that arbitrary
        // Android applications can generate intents with extra data and that
        // there are many security-sensitive args in the binary.
        ArrayList<String> args = new ArrayList<String>();
        if (intent.getBooleanExtra("trace-startup", false)) {
            args.add("--trace-startup");
        }
        if (intent.getBooleanExtra("start-paused", false)) {
            args.add("--start-paused");
        }
        if (intent.getBooleanExtra("enable-dart-profiling", false)) {
            args.add("--enable-dart-profiling");
        }
        if (!args.isEmpty()) {
            String[] argsArray = new String[args.size()];
            return args.toArray(argsArray);
        }
        return null;
    }
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String[] args = getArgsFromIntent(getIntent());
        FlutterMain.ensureInitializationComplete(getApplicationContext(), args);
        setContentView(R.layout.full_screen_flutter_layout);
        getSupportActionBar().hide();

        flutterView = (FlutterView) findViewById(R.id.full_flutter_view);
        flutterView.runFromBundle(FlutterMain.findAppBundlePath(getApplicationContext()), null);
//
//        flutterView.addOnMessageListener(CHANNEL,
//                new FlutterView.OnMessageListener() {
//                    @Override
//                    public String onMessage(FlutterView view, String message) {
//                        return onFlutterIncrement();
//                    }
//                });
//
//        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.button);
//        fab.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                sendAndroidIncrement();
//            }
//        });
    }
}
