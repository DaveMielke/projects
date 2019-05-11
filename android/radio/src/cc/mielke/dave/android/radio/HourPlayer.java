package cc.mielke.dave.android.radio;

import static cc.mielke.dave.android.base.TimeConstants.*;

public class HourPlayer extends TimePlayer {
  public HourPlayer () {
    super();
  }

  private final static long THRESHOLD = SECOND.UNIT.toMillis(10);
  private Long previousHour = null;

  @Override
  public void reset () {
    super.reset();
    previousHour = null;
  }

  @Override
  public final boolean play () {
    long now = getCurrentTime();
    long time = now + THRESHOLD;
    long hour = HOUR.START(time);
    setEarliestTime(hour + HOUR.ONE - THRESHOLD);

    {
      boolean announce =
        (previousHour == null)?
        ((time - hour) < MINUTE.ONE):
        (hour != previousHour);

      previousHour = hour;
      if (!announce) return false;
    }

    return play(time);
  }
}
