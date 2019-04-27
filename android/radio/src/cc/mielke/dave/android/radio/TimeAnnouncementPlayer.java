package cc.mielke.dave.android.radio;

import java.util.concurrent.TimeUnit;

import java.text.SimpleDateFormat;
import android.text.format.DateFormat;

public abstract class TimeAnnouncementPlayer extends SpeechPlayer {
  public TimeAnnouncementPlayer (RadioProgram program) {
    super(program);
  }

  protected final static long ONE_HOUR = TimeUnit.HOURS.toMillis(1);
  protected final static long HALF_HOUR = ONE_HOUR / 2;

  protected final static long ONE_MINUTE = TimeUnit.MINUTES.toMillis(1);
  protected final static long HALF_MINUTE = ONE_MINUTE / 2;

  protected final String toTimeString (long time) {
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
}
