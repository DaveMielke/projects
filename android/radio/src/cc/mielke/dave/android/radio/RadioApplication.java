package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseApplication;

public class RadioApplication extends BaseApplication {
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
