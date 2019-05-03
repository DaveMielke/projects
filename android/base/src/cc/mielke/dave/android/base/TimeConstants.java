package cc.mielke.dave.android.base;

import java.util.concurrent.TimeUnit;

public abstract class TimeConstants {
  public TimeConstants () {
  }

  public final static long ONE_HOUR = TimeUnit.HOURS.toMillis(1);
  public final static long HALF_HOUR = ONE_HOUR / 2;

  public final static long ONE_MINUTE = TimeUnit.MINUTES.toMillis(1);
  public final static long HALF_MINUTE = ONE_MINUTE / 2;

  public final static long ONE_SECOND = TimeUnit.SECONDS.toMillis(1);
  public final static long HALF_SECOND = ONE_SECOND / 2;

  public final static long SECONDS_PER_MINUTE = ONE_MINUTE / ONE_SECOND;
  public final static long MINUTES_PER_HOUR = ONE_HOUR / ONE_MINUTE;

  public final static String ISO_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS";
}
