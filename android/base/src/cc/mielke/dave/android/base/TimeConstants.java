package cc.mielke.dave.android.base;

import java.util.concurrent.TimeUnit;

public enum TimeConstants {
  SECOND(TimeUnit.SECONDS),
  MINUTE(TimeUnit.MINUTES),
  HOUR(TimeUnit.HOURS),
  DAY(TimeUnit.DAYS),
  ; // end of enumeration

  public final TimeUnit UNIT;
  public final long ONE;
  public final long HALF;

  TimeConstants (TimeUnit unit) {
    UNIT = unit;
    ONE = UNIT.toMillis(1);
    HALF = ONE / 2;
  }

  public final static long SECONDS_PER_MINUTE = MINUTE.ONE / SECOND.ONE;
  public final static long MINUTES_PER_HOUR = HOUR.ONE / MINUTE.ONE;
}
