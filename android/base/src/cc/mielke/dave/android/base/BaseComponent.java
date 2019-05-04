package cc.mielke.dave.android.base;

import java.util.Arrays;
import java.util.Comparator;

import java.util.Properties;

import java.text.SimpleDateFormat;
import cc.mielke.dave.android.base.TimeConstants;

import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.Reader;
import java.io.InputStreamReader;

import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.io.IOException;

import android.util.Log;

import android.content.Context;
import android.content.res.Resources;
import android.os.Handler;

import android.app.AlarmManager;
import android.media.AudioManager;

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

  protected static long getCurrentTime () {
    return System.currentTimeMillis();
  }

  protected static String toTimeString (long time, String format) {
    return new SimpleDateFormat(format).format(time);
  }

  protected static String toTimeString (long time) {
    return toTimeString(time, TimeConstants.DISPLAY_FORMAT);
  }

  protected static String toTimeString () {
    return toTimeString(getCurrentTime());
  }

  protected static Handler getHandler () {
    return BaseApplication.getHandler();
  }

  protected static void post (Runnable callback) {
    getHandler().post(callback);
  }

  protected static void postAt (final long when, final Runnable callback) {
    if (ApiTests.HAVE_OnAlarmListener) {
      AlarmManager am = getAlarmManager();

      AlarmManager.OnAlarmListener listener =
        new AlarmManager.OnAlarmListener() {
          @Override
          public void onAlarm () {
            callback.run();
          }
        };

      am.setExact(
        AlarmManager.RTC_WAKEUP, when, "delayed-post", listener, null
      );
    } else {
      postIn((when - getCurrentTime()), callback);
    }
  }

  protected static void postIn (final long delay, final Runnable callback) {
    if (ApiTests.HAVE_OnAlarmListener) {
      postAt((getCurrentTime() + delay), callback);
    } else {
      getHandler().postDelayed(callback, delay);
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

  protected static Properties loadProperties (Reader reader) {
    Properties properties = new Properties();

    try {
      properties.load(reader);
      return properties;
    } catch (IOException exception) {
      Log.e(LOG_TAG, ("properties load error: " + exception.getMessage()));
    }

    return null;
  }

  protected static Properties loadProperties (InputStream stream) {
    String encoding = "UTF-8";

    try {
      Reader reader = new InputStreamReader(stream, encoding);
      try {
        return loadProperties(reader);
      } finally {
        try {
          reader.close();
        } catch (IOException exception) {
          Log.w(LOG_TAG, ("property reader close error: " + exception.getMessage()));
        }
      }
    } catch (UnsupportedEncodingException exception) {
      Log.e(LOG_TAG, ("unsupported character encoding" + encoding));
    }

    return null;
  }

  protected static Properties loadProperties (File file) {
    try {
      InputStream stream = new FileInputStream(file);
      try {
        return loadProperties (stream);
      } finally {
        try {
          stream.close();
        } catch (IOException exception) {
          Log.w(LOG_TAG, ("property stream close error: " + exception.getMessage()));
        }
      }
    } catch (FileNotFoundException exception) {
      Log.e(LOG_TAG, ("properties file not found: " + exception.getMessage()));
    }

    return null;
  }

  protected static Properties loadProperties (String file) {
    return loadProperties (new File(file));
  }
}
