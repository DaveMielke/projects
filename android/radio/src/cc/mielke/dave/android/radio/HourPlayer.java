package cc.mielke.dave.android.radio;

import static cc.mielke.dave.android.base.TimeConstants.*;

public class HourPlayer extends TimePlayer {
  public HourPlayer () {
    super();
  }

  private Long previousHour = null;

  @Override
  public final boolean play () {
    long now = getCurrentTime();
    long time = now + MINUTE.HALF;
    long hour = (time / HOUR.ONE) * HOUR.ONE;

    {
      long next = hour + HOUR.ONE - MINUTE.HALF;
      setEarliestTime(next);
    }

    {
      boolean announce =
        (previousHour == null)?
        (Math.abs(now - hour) <= MINUTE.HALF):
        (hour != previousHour);

      previousHour = hour;
      if (!announce) return false;
    }

    return play(time);
  }
}
