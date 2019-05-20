package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class CurrentProgram extends CurrentSelection {
  private final static String LOG_TAG = CurrentProgram.class.getName();

  protected CurrentProgram () {
    super();
  }

  private final static Object CURRENT_PROGRAM_LOCK = new Object();
  private static RadioProgram currentProgram = null;

  public static RadioProgram getProgram () {
    synchronized (CURRENT_PROGRAM_LOCK) {
      return currentProgram;
    }
  }

  private static String getName () {
    return RadioProgram.getExternalName(getProgram());
  }

  public static void setProgram (RadioProgram newProgram) {
    synchronized (CURRENT_PROGRAM_LOCK) {
      if (newProgram != currentProgram) {
        if (currentProgram != null) currentProgram.stop();

        String oldName = getName();
        currentProgram = newProgram;
        String newName = getName();

        logSelectionChange("program", oldName, newName);
        watcher.onProgramChange(currentProgram);

        if (currentProgram != null) {
          currentProgram.start();
        } else {
          updateNotification();
        }
      }
    }
  }
}
