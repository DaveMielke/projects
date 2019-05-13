package cc.mielke.dave.android.base;

import java.util.Properties;

import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;

import java.io.InputStream;
import java.io.FileInputStream;

import java.io.Reader;
import java.io.InputStreamReader;

import android.util.Log;

public abstract class PropertiesHelper extends BaseComponent {
  private final static String LOG_TAG = PropertiesHelper.class.getName();

  private PropertiesHelper () {
  }

  public static Properties load (Reader reader) {
    Properties properties = new Properties();

    try {
      properties.load(reader);
      return properties;
    } catch (IOException exception) {
      Log.e(LOG_TAG, ("properties load error: " + exception.getMessage()));
    }

    return null;
  }

  public static Properties load (InputStream stream) {
    String encoding = "UTF-8";

    try {
      Reader reader = new InputStreamReader(stream, encoding);
      try {
        return load(reader);
      } finally {
        try {
          reader.close();
        } catch (IOException exception) {
          Log.w(LOG_TAG, ("reader close error: " + exception.getMessage()));
        }
      }
    } catch (UnsupportedEncodingException exception) {
      Log.e(LOG_TAG, ("unsupported character encoding" + encoding));
    }

    return null;
  }

  public static Properties load (File file) {
    try {
      InputStream stream = new FileInputStream(file);
      try {
        return load(stream);
      } finally {
        try {
          stream.close();
        } catch (IOException exception) {
          Log.w(LOG_TAG, ("stream close error: " + exception.getMessage()));
        }
      }
    } catch (FileNotFoundException exception) {
      Log.w(LOG_TAG, ("file not found: " + exception.getMessage()));
    }

    return null;
  }

  public static Properties load (String file) {
    return load(new File(file));
  }
}
