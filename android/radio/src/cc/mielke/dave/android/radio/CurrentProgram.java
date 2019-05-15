package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class CurrentProgram extends RadioComponent {
  private final static String LOG_TAG = CurrentProgram.class.getName();

  private CurrentProgram () {
  }

  private final static Object CURRENT_PROGRAM_LOCK = new Object();
  private static RadioProgram currentProgram = null;

  public static RadioProgram get () {
    synchronized (CURRENT_PROGRAM_LOCK) {
      return currentProgram;
    }
  }

  private static String getName () {
    return RadioProgram.getExternalName(get());
  }

  public static void set (RadioProgram newProgram) {
    synchronized (CURRENT_PROGRAM_LOCK) {
      if (newProgram != currentProgram) {
        StringBuilder log = new StringBuilder("changing program: ");

        log.append(getName());
        if (currentProgram != null) currentProgram.stop();

        currentProgram = newProgram;
        log.append(" -> ");
        log.append(getName());
        Log.i(LOG_TAG, log.toString());

        if (currentProgram != null) {
          currentProgram.start();
        } else {
          updateNotification();
        }
      }
    }
  }
}
