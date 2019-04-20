package cc.mielke.dave.android.radio;

import android.app.Application;
import android.content.Context;

public class RadioApplication extends Application {
  private static Context applicationContext = null;
  private static FileGenerator musicGenerator = null;
  private static FileGenerator bookGenerator = null;

  @Override
  public void onCreate () {
    super.onCreate();
    applicationContext = this;

    musicGenerator = new MusicGenerator();
    bookGenerator = new BookGenerator();
  }

  public static Context getContext () {
    return applicationContext;
  }

  public static FileGenerator getMusicGenerator () {
    return musicGenerator;
  }

  public static FileGenerator getBookGenerator () {
    return bookGenerator;
  }
}
