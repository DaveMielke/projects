package cc.mielke.dave.android.base;

import android.text.format.DateFormat;
import android.content.Context;

public abstract class TimeHelper {
  private TimeHelper () {
  }

  public final static String DATE_FORMAT = "yyyy-MM-dd";
  public final static String TIME_FORMAT_24 = "HH:mm:ss";
  public final static String TIME_FORMAT_12 = "hh:mm:ssa";
  public final static String DATE_TIME_DELIMITER = "@";

  public static boolean is24HourMode (Context context) {
    return DateFormat.is24HourFormat(context);
  }

  public static String getTimeFormat (Context context, boolean withDate) {
    String format = is24HourMode(context)? TIME_FORMAT_24: TIME_FORMAT_12;
    if (!withDate) return format;
    return DATE_FORMAT + "'" + DATE_TIME_DELIMITER + "'" + format;
  }
}
