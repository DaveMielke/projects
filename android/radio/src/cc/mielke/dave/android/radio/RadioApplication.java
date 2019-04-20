package cc.mielke.dave.android.radio;

import android.app.Application;
import android.content.Context;

public class RadioApplication extends Application {
  private static Context applicationContext;

  @Override
  public void onCreate () {
    super.onCreate();
    applicationContext = this;
  }

  public static Context getContext () {
    return applicationContext;
  }
}
