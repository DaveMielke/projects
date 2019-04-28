package cc.mielke.dave.android.base;

import java.io.File;

import android.os.Environment;
import android.app.Application;
import android.content.pm.ApplicationInfo;

import android.content.Context;
import android.os.Handler;

public class BaseApplication extends Application {
  private static Context applicationContext = null;
  private static Handler applicationHandler = null;

  @Override
  public void onCreate () {
    super.onCreate();
    applicationContext = this;
    applicationHandler = new Handler();
  }

  public static Context getContext () {
    return applicationContext;
  }

  public static Handler getHandler () {
    return applicationHandler;
  }

  public static String getName (Context context) {
    ApplicationInfo info = context.getApplicationInfo();
    int label = info.labelRes;
    return (label == 0)? info.nonLocalizedLabel.toString(): context.getString(label);
  }

  public static String getName () {
    Context context = getContext();
    if (context == null) return null;
    return getName(context);
  }

  public static File getExternalStorageDirectory () {
    File directory = Environment.getExternalStorageDirectory();
    if (directory == null) return null;

    directory = new File(directory, getName());
    return directory;
  }
}
