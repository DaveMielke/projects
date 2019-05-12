package cc.mielke.dave.android.base;

import java.io.File;

import android.os.Environment;
import android.app.Application;
import android.content.pm.ApplicationInfo;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

public class BaseApplication extends Application {
  private final static Object CONTEXT_LOCK = new Object();
  private static Context applicationContext = null;
  private static Handler applicationHandler = null;

  public static boolean setContext (Context context) {
    synchronized (CONTEXT_LOCK) {
      if (applicationContext != null) return false;
      applicationContext = context.getApplicationContext();
      return true;
    }
  }

  @Override
  public void onCreate () {
    super.onCreate();
    setContext(this);
  }

  public static Context getContext () {
    synchronized (CONTEXT_LOCK) {
      return applicationContext;
    }
  }

  public static Handler getHandler () {
    synchronized (CONTEXT_LOCK) {
      if (applicationHandler == null) applicationHandler = new Handler(Looper.getMainLooper());
      return applicationHandler;
    }
  }

  public static String getName (Context context) {
    ApplicationInfo info = context.getApplicationInfo();

    {
      int label = info.labelRes;
      if (label != 0) return context.getString(label);
    }

    return info.nonLocalizedLabel.toString();
  }

  public static String getName () {
    Context context = getContext();
    if (context == null) return null;
    return getName(context);
  }

  public static File getExternalStorageDirectory () {
    File directory = Environment.getExternalStorageDirectory();
    if (directory == null) return null;

    String name = getName();
    if (name == null) return null;

    return new File(directory, name);
  }
}
