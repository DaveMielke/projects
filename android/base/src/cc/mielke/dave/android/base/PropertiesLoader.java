package cc.mielke.dave.android.base;

import java.io.IOException;
import java.io.Reader;
import java.util.Properties;

import android.util.Log;

public abstract class PropertiesLoader extends CharacterLoader {
  private final static String LOG_TAG = PropertiesLoader.class.getName();

  protected PropertiesLoader () {
    super();
  }

  protected abstract void load (Properties properties, String name);

  @Override
  protected final void load (Reader reader, String name) {
    Properties properties = new Properties();

    try {
      properties.load(reader);
      load(properties, name);
    } catch (IOException exception) {
      Log.w(LOG_TAG, ("properties load error: " + exception.getMessage()));
    }
  }
}
