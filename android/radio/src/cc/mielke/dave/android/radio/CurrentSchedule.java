package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class CurrentSchedule extends CurrentSelection {
  private final static String LOG_TAG = CurrentSchedule.class.getName();

  protected CurrentSchedule () {
    super();
  }

  private final static Object CURRENT_SCHEDULE_LOCK = new Object();
  private static RadioSchedule currentSchedule = null;

  public static RadioSchedule getSchedule () {
    synchronized (CURRENT_SCHEDULE_LOCK) {
      return currentSchedule;
    }
  }

  private static String getName () {
    return RadioSchedule.getExternalName(getSchedule());
  }

  public static void setSchedule (RadioSchedule newSchedule) {
    synchronized (CURRENT_SCHEDULE_LOCK) {
      if (newSchedule != currentSchedule) {
        if (currentSchedule != null) currentSchedule.stop();

        String oldName = getName();
        currentSchedule = newSchedule;
        String newName = getName();

        logSelectionChange("schedule", oldName, newName);
        watcher.onScheduleChange(currentSchedule);
        if (currentSchedule != null) currentSchedule.start();
      }
    }
  }
}
