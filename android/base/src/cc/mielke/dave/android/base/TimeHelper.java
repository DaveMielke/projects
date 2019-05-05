package cc.mielke.dave.android.base;

import android.text.format.DateFormat;
import android.content.Context;

public abstract class TimeHelper {
  private TimeHelper () {
  }

  public final static String TIME_FORMAT_24 = "yyyy-MM-dd'@'HH:mm:ss";
  public final static String TIME_FORMAT_12 = "yyyy-MM-dd'@'hh:mm:ssa";

  public static boolean is24HourMode (Context context) {
    return DateFormat.is24HourFormat(context);
  }

  public static String getTimeFormat (Context context) {
    return is24HourMode(context)? TIME_FORMAT_24: TIME_FORMAT_12;
  }
}
