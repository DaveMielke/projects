package cc.mielke.dave.android.radio;

import android.app.Application;
import android.content.Context;

public class RadioApplication extends Application {
  private static Context applicationContext = null;
  private static RadioPlayer musicPlayer = null;
  private static RadioPlayer bookPlayer = null;

  @Override
  public void onCreate () {
    super.onCreate();
    applicationContext = this;

    musicPlayer = new MusicPlayer();
    bookPlayer = new BookPlayer();
  }

  public static Context getContext () {
    return applicationContext;
  }

  public static RadioPlayer getMusicPlayer () {
    return musicPlayer;
  }

  public static RadioPlayer getBookPlayer () {
    return bookPlayer;
  }
}
