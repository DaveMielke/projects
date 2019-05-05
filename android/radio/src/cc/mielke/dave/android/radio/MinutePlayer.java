package cc.mielke.dave.android.radio;

import static cc.mielke.dave.android.base.TimeConstants.*;

public class MinutePlayer extends TimePlayer {
  public MinutePlayer () {
    super();
  }

  @Override
  public final boolean play () {
    long now = getCurrentTime();

    {
      long next = ((now + MINUTE.ONE) / MINUTE.ONE) * MINUTE.ONE;
      setEarliestTime(next);
    }

    return play(now);
  }
}
