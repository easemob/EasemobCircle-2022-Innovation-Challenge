package io.agora.service;


import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.multidex.MultiDex;

import com.alibaba.android.arouter.launcher.ARouter;
import com.blankj.utilcode.util.Utils;
import com.scwang.smartrefresh.layout.SmartRefreshLayout;
import com.scwang.smartrefresh.layout.api.DefaultRefreshHeaderCreator;
import com.scwang.smartrefresh.layout.api.RefreshHeader;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.header.ClassicsHeader;
import com.tencent.bugly.crashreport.CrashReport;

import io.agora.service.db.DatabaseManager;
import io.agora.service.global.GlobalServer;
import io.agora.service.global.UserActivityLifecycleCallbacks;
import io.agora.service.managers.PreferenceManager;

public class BaseApplication extends Application {
    private static Context context;
    private UserActivityLifecycleCallbacks mLifecycleCallbacks = new UserActivityLifecycleCallbacks();

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        //65535
        MultiDex.install(this);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        context = this;
        if (BuildConfig.DEBUG) {           // These two lines must be written before init, otherwise these configurations will be invalid in the init process
            ARouter.openLog();     // Print log
            ARouter.openDebug();   // Turn on debugging mode (If you are running in InstantRun mode, you must turn on debug mode! Online version needs to be closed, otherwise there is a security risk)
        }
        ARouter.init(this); // As early as possible, it is recommended to initialize in the Application

        Utils.init(this);
        PreferenceManager.init(this);
        DatabaseManager.getInstance().init(this);
        registerActivityLifecycleCallbacks();
        if (GlobalServer.getInstance().getAutoLogin()) {
            GlobalServer.getInstance().initHX(this);
        }

        SmartRefreshLayout.setDefaultRefreshHeaderCreator(new DefaultRefreshHeaderCreator() {
            @NonNull
            @Override
            public RefreshHeader createRefreshHeader(@NonNull Context context, @NonNull RefreshLayout layout) {
                return new ClassicsHeader(context);
            }
        });
//        CrashReport.initCrashReport(getApplicationContext(), BuildConfig.CIRCLE_BUGLY_APPID, false);
        CrashReport.initCrashReport(getApplicationContext(), "e9527ae96f", false);
    }

    public static Context getContext() {
        return context;
    }

    private void registerActivityLifecycleCallbacks() {
        this.registerActivityLifecycleCallbacks(mLifecycleCallbacks);
    }

    public UserActivityLifecycleCallbacks getLifecycleCallbacks() {
        return mLifecycleCallbacks;
    }
}
