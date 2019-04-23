package cc.mielke.dave.android.base;

import java.util.Arrays;
import java.util.Comparator;

import java.util.Properties;

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
import android.os.Handler;

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

  private final static Object HANDLER_LOCK = new Object();
  private static Handler handler = null;

  protected static Handler getHandler () {
    synchronized (HANDLER_LOCK) {
      if (handler == null) handler = new Handler();
      return handler;
    }
  }

  protected static void post (Runnable runnable) {
    getHandler().post(runnable);
  }

  protected static void post (long delay, Runnable runnable) {
    getHandler().postDelayed(runnable, delay);
  }

  protected static long getCurrentTime () {
    return System.currentTimeMillis();
  }

  protected void sort (String[] strings) {
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
