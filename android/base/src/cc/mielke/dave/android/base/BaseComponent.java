package cc.mielke.dave.android.base;

import java.util.Arrays;
import java.util.Comparator;

import java.util.Map;
import java.util.HashMap;

import cc.mielke.dave.android.base.TimeHelper;
import java.text.SimpleDateFormat;

import java.io.File;

import android.util.Log;

import android.content.Context;
import android.content.res.Resources;

import android.os.Looper;
import android.os.Handler;

import android.app.AlarmManager;
import android.media.AudioManager;
import android.os.PowerManager;

public abstract class BaseComponent {
  private final static String LOG_TAG = BaseComponent.class.getName();

  protected BaseComponent () {
    super();
  }

  protected static Context getContext () {
    return BaseApplication.getContext();
  }

  protected static String getString (int string) {
    return getContext().getString(string);
  }

  protected static Resources getResources () {
    return getContext().getResources();
  }

  protected static AlarmManager getAlarmManager () {
    return (AlarmManager)getContext().getSystemService(Context.ALARM_SERVICE);
  }

  protected static AudioManager getAudioManager () {
    return (AudioManager)getContext().getSystemService(Context.AUDIO_SERVICE);
  }

  protected static PowerManager getPowerManager () {
    return (PowerManager)getContext().getSystemService(Context.POWER_SERVICE);
  }

  protected static long getCurrentTime () {
    return System.currentTimeMillis();
  }

  protected static boolean is12HourMode () {
    return TimeHelper.is12HourMode(getContext());
  }

  protected static String getTimeFormat (boolean withDate) {
    return TimeHelper.getTimeFormat(getContext(), withDate, false);
  }

  protected static String getTimeFormat () {
    return getTimeFormat(false);
  }

  protected static String toTimeString (long time, String format) {
    return new SimpleDateFormat(format).format(time);
  }

  protected static String toTimeString (long time) {
    return toTimeString(time, getTimeFormat());
  }

  protected static String toTimeString () {
    return toTimeString(getCurrentTime());
  }

  protected static Looper getMainLooper () {
    return Looper.getMainLooper();
  }

  protected final static Handler mainHandler = new Handler(getMainLooper());
  private final static Map<Runnable, AlarmManager.OnAlarmListener> callbackAlarms;

  static {
    if (ApiTests.HAVE_AlarmManager_OnAlarmListener) {
      callbackAlarms = new HashMap<>();
    } else {
      callbackAlarms = null;
    }
  }

  protected static void unpost (Runnable callback) {
    mainHandler.removeCallbacks(callback);

    if (ApiTests.HAVE_AlarmManager_OnAlarmListener) {
      synchronized (callbackAlarms) {
        AlarmManager.OnAlarmListener listener = callbackAlarms.remove(callback);
        if (listener != null) getAlarmManager().cancel(listener);
      }
    }
  }

  protected static void postAt (final long when, final Runnable callback) {
    if (ApiTests.HAVE_AlarmManager_OnAlarmListener) {
      AlarmManager.OnAlarmListener listener =
        new AlarmManager.OnAlarmListener() {
          @Override
          public void onAlarm () {
            synchronized (callbackAlarms) {
              AlarmManager.OnAlarmListener listener = callbackAlarms.remove(callback);

              if (listener == null) {
                throw new IllegalStateException("callback not mapped");
              }

              if (listener != this) {
                throw new IllegalStateException("callback mapped to different alarm");
              }
            }

            callback.run();
          }
        };

      synchronized (callbackAlarms) {
        if (callbackAlarms.get(callback) != null) {
          throw new IllegalStateException("callback already mapped");
        }

        callbackAlarms.put(callback, listener);

        getAlarmManager().setExact(
          AlarmManager.RTC_WAKEUP, when, "delayed-post", listener, null
        );
      }
    } else {
      postIn((when - getCurrentTime()), callback);
    }
  }

  protected static void postIn (final long delay, final Runnable callback) {
    if (ApiTests.HAVE_AlarmManager_OnAlarmListener) {
      postAt((getCurrentTime() + delay), callback);
    } else {
      mainHandler.postDelayed(callback, delay);
    }
  }

  protected static void postNow (Runnable callback) {
    mainHandler.post(callback);
  }

  protected static Thread getMainThread () {
    return getMainLooper().getThread();
  }

  protected static boolean amOnMainThread () {
    return Thread.currentThread() == getMainThread();
  }

  protected static void runOnMainThread (Runnable task) {
    if (amOnMainThread()) {
      task.run();
    } else {
      postNow(task);
    }
  }

  protected static File getExternalStorageDirectory () {
    return BaseApplication.getExternalStorageDirectory();
  }

  protected static void sort (String[] strings) {
    Arrays.sort(
      strings,
      new Comparator<String>() {
        @Override
        public int compare (String string1, String string2) {
          return string1.compareTo(string2);
        }
      }
    );
  }
}
