package cc.mielke.dave.android.radio;

import java.util.concurrent.TimeUnit;

public class HourlyPlayer extends TextPlayer {
  public HourlyPlayer () {
    super();
  }

  private final static long ONE_HOUR = TimeUnit.HOURS.toMillis(1);
  private final static long HALF_HOUR = ONE_HOUR / 2;

  private final static long ONE_MINUTE = TimeUnit.MINUTES.toMillis(1);
  private final static long HALF_MINUTE = ONE_MINUTE / 2;

  private static Long previousHour = null;

  @Override
  public final boolean play () {
    long now = getCurrentTime();
    long hour = ((now + HALF_MINUTE) / ONE_HOUR) * ONE_HOUR;

    boolean first = previousHour == null;
    previousHour = hour;

    long next = hour + ONE_HOUR - HALF_MINUTE;
    setEarliestTime(next);

    if (first) {
      if (Math.abs(now - hour) > HALF_MINUTE) return false;
    } else if (hour == previousHour) {
      return false;
    }

    return play(String.format("It's %d o'clock.", hour));
  }
}
