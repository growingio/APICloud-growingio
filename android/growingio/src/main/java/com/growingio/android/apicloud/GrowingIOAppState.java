package com.growingio.android.apicloud;

import android.annotation.Nullable;
import android.app.Activity;

import com.uzmap.pkg.uzcore.uzmodule.AppInfo;
import com.uzmap.pkg.uzcore.uzmodule.ApplicationDelegate;

import java.lang.ref.WeakReference;

/**
 * 为了记录currentActivity
 * Created by liangdengke on 2018/6/20.
 */
public class GrowingIOAppState extends ApplicationDelegate{

    private static WeakReference<Activity> currentActivity;

    @Override
    public void onActivityResume(Activity activity, AppInfo info) {
        super.onActivityResume(activity, info);
        currentActivity = new WeakReference<>(activity);
    }

    @Override
    public void onActivityPause(Activity activity, AppInfo info) {
        super.onActivityPause(activity, info);
        currentActivity = null;
    }

    @Nullable
    public static Activity currentActivity(){
        return currentActivity == null ? null : currentActivity.get();
    }
}
