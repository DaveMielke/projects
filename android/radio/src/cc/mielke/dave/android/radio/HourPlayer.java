package cc.mielke.dave.android.radio;

public class HourPlayer extends TimePlayer {
  public HourPlayer () {
    super();
  }

  private Long previousHour = null;

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
