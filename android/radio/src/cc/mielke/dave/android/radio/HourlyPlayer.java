package cc.mielke.dave.android.radio;

import java.util.concurrent.TimeUnit;

import java.text.SimpleDateFormat;
import android.text.format.DateFormat;

public class HourlyPlayer extends TextPlayer {
  public HourlyPlayer (RadioProgram program) {
    super(program);
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

    {
      StringBuilder text = new StringBuilder();
      boolean use24HourFormat = DateFormat.is24HourFormat(getContext());
      String format = use24HourFormat? "H": "h a";

      text.append("It's ");
      text.append(new SimpleDateFormat(format).format(hour));
      if (use24HourFormat) text.append(" o'clock");
      text.append('.');

      return play(text.toString());
    }
  }
}
