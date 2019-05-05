package cc.mielke.dave.android.base;

import android.text.format.DateFormat;
import android.content.Context;

public abstract class TimeHelper {
  private TimeHelper () {
  }

  public final static String DATE_FORMAT = "yyyy-MM-dd";
  public final static String TIME_FORMAT_24 = "HH:mm:ss";
  public final static String TIME_FORMAT_12 = "h:mm:ss";
  public final static String AM_PM_FORMAT = "a";
  public final static String DATE_TIME_DELIMITER = "@";

  public static String getTimeFormat (boolean as12Hours, boolean withDate, boolean withMilliseconds) {
    String format = as12Hours? TIME_FORMAT_12: TIME_FORMAT_24;

    if (withDate) {
      StringBuilder fmt = new StringBuilder();
      fmt.append(DATE_FORMAT);

      String quote = "'";
      fmt.append(quote);
      fmt.append(DATE_TIME_DELIMITER);
      fmt.append(quote);

      if (as12Hours) fmt.append(format.charAt(0));
      fmt.append(format);

      format = fmt.toString();
    }

    if (withMilliseconds) format += ".SSS";
    if (as12Hours) format += AM_PM_FORMAT;
    return format;
  }

  public static boolean is12HourMode (Context context) {
    return !DateFormat.is24HourFormat(context);
  }

  public static String getTimeFormat (Context context, boolean withDate, boolean withMilliseconds) {
    return getTimeFormat(is12HourMode(context), withDate, withMilliseconds);
  }
}
