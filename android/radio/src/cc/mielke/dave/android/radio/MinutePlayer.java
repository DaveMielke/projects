package cc.mielke.dave.android.radio;

import static cc.mielke.dave.android.base.TimeConstants.*;

public class MinutePlayer extends TimePlayer {
  public MinutePlayer () {
    super();
  }

  @Override
  public final boolean play () {
    long now = getCurrentTime();
    setEarliestTime(MINUTE.START(now + MINUTE.ONE));
    return play(now);
  }
}
