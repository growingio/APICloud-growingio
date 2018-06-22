package com;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.Application;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import com.uzmap.pkg.uzapp.UZApplication;

/**
 * Created by liangdengke on 2018/6/20.
 */
@TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
public class App extends UZApplication implements Application.ActivityLifecycleCallbacks {
    private static final String TAG = "APP";

    @Override
    public void onCreate() {
        super.onCreate();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
            registerActivityLifecycleCallbacks(this);
        }
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        Log.d(TAG, "onCreate: " + activity);
    }

    @Override
    public void onActivityDestroyed(Activity activity) {

    }

    @Override
    public void onActivityPaused(Activity activity) {
        Log.d(TAG, "onPaused: " + activity);
    }

    @Override
    public void onActivityResumed(Activity activity) {
        Log.d(TAG, "onResumed: " + activity);
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

    }

    @Override
    public void onActivityStarted(Activity activity) {

    }

    @Override
    public void onActivityStopped(Activity activity) {

    }
}
