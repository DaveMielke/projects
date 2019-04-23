package cc.mielke.dave.android.radio;

import java.util.concurrent.TimeUnit;

import java.text.SimpleDateFormat;
import android.text.format.DateFormat;

public class HourlyAnnouncementPlayer extends TextPlayer {
  public HourlyAnnouncementPlayer (RadioProgram program) {
    super(program);
  }

  private final static long ONE_HOUR = TimeUnit.HOURS.toMillis(1);
  private final static long HALF_HOUR = ONE_HOUR / 2;

  private final static long ONE_MINUTE = TimeUnit.MINUTES.toMillis(1);
  private final static long HALF_MINUTE = ONE_MINUTE / 2;

  private static Long previousHour = null;

  private static String toTimeString (long time) {
    boolean use24HourFormat = DateFormat.is24HourFormat(getContext());
    String format = use24HourFormat? "H": "h";
    SimpleDateFormat formatter = new SimpleDateFormat(format);

    StringBuilder text = new StringBuilder();
    text.append("It's ");

    text.append(formatter.format(time));
    text.append(' ');

    {
      long minutes = TimeUnit.MILLISECONDS.toMinutes(time % ONE_HOUR);

      if (minutes > 0) {
        if (minutes < 10) text.append("o ");
        text.append(minutes);
      } else if (use24HourFormat) {
        text.append("o'clock");
      }
    }

    if (!use24HourFormat) {
      formatter.applyPattern("a");
      text.append(' ');
      text.append(formatter.format(time));
    }

    text.append('.');
    return text.toString();
  }

  @Override
  public final boolean play () {
    long now = getCurrentTime();
    long time = now + HALF_MINUTE;
    long hour = (time / ONE_HOUR) * ONE_HOUR;

    {
      long next = hour + ONE_HOUR - HALF_MINUTE;
      setEarliestTime(next);
    }

    {
      boolean announce =
        (previousHour == null)?
        (Math.abs(now - hour) <= HALF_MINUTE):
        (hour != previousHour);

      previousHour = hour;
      if (!announce) return false;
    }

    return play(toTimeString(time));
  }
}
