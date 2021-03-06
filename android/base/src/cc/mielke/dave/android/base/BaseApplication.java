package cc.mielke.dave.android.base;

import java.io.File;

import android.os.Environment;
import android.app.Application;
import android.content.pm.ApplicationInfo;

import android.content.Context;

public class BaseApplication extends Application {
  protected final static Object APPLICATION_LOCK = new Object();
  private static Context applicationContext = null;

  public static void setContext (Context context) {
    synchronized (APPLICATION_LOCK) {
      if (applicationContext == null) {
        applicationContext = context.getApplicationContext();
      }
    }
  }

  @Override
  public void onCreate () {
    super.onCreate();
    setContext(this);
  }

  public static Context getContext () {
    synchronized (APPLICATION_LOCK) {
      return applicationContext;
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
