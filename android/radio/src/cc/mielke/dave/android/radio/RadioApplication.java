package cc.mielke.dave.android.radio;

import android.app.Application;
import android.content.Context;

public class RadioApplication extends Application {
  private static Context applicationContext = null;

  @Override
  public void onCreate () {
    super.onCreate();
    applicationContext = this;
  }

  public static Context getContext () {
    return applicationContext;
  }

  private final static Object PROGRAM_LOCK = new Object();
  private static RadioProgram radioProgram = null;

  public static RadioProgram getProgram () {
    synchronized (PROGRAM_LOCK) {
      return radioProgram;
    }
  }

  public static void setProgram (RadioProgram program) {
    synchronized (PROGRAM_LOCK) {
      if (radioProgram != null) radioProgram.stop();
      radioProgram = program;
      if (radioProgram != null) radioProgram.start();
    }
  }
}
