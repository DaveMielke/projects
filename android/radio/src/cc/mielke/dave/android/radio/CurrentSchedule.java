package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class CurrentSchedule extends RadioComponent {
  private final static String LOG_TAG = CurrentSchedule.class.getName();

  private CurrentSchedule () {
  }

  private final static Object CURRENT_SCHEDULE_LOCK = new Object();
  private static RadioSchedule currentSchedule = null;

  public static RadioSchedule get () {
    synchronized (CURRENT_SCHEDULE_LOCK) {
      return currentSchedule;
    }
  }

  private static String getName () {
    return RadioSchedule.getExternalName(get());
  }

  public static void set (RadioSchedule newSchedule) {
    synchronized (CURRENT_SCHEDULE_LOCK) {
      if (newSchedule != currentSchedule) {
        StringBuilder log = new StringBuilder("changing schedule: ");

        log.append(getName());
        if (currentSchedule != null) currentSchedule.stop();

        currentSchedule = newSchedule;
        log.append(" -> ");
        log.append(getName());
        Log.i(LOG_TAG, log.toString());

        if (currentSchedule != null) currentSchedule.start();
      }
    }
  }
}
