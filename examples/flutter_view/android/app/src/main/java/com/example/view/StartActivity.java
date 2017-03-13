package com.example.view;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

/**
 * Created by zarah on 3/9/17.
 */

public class StartActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_layout_xml);
        getSupportActionBar().hide();
    }

    public void chooseSplitView(View view) {
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
    }

    public void chooseFullView(View view) {
        Intent intent = new Intent(this, FullFlutterActivity.class);
        startActivity(intent);
    }

}
