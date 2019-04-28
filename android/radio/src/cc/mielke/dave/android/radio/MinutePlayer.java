package cc.mielke.dave.android.radio;

public class MinutePlayer extends TimePlayer {
  public MinutePlayer () {
    super();
  }

  @Override
  public final boolean play () {
    long now = getCurrentTime();

    {
      long next = ((now + ONE_MINUTE) / ONE_MINUTE) * ONE_MINUTE;
      setEarliestTime(next);
    }

    return play(toTimeString(now));
  }
}
