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

  private final static AbstractGenerator musicGenerator = new MusicGenerator();
  private final static AbstractGenerator bookGenerator = new BookGenerator();

  public static AbstractGenerator getMusicGenerator () {
    return musicGenerator;
  }

  public static AbstractGenerator getBookGenerator () {
    return bookGenerator;
  }
}
