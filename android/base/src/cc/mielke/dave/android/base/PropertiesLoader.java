package cc.mielke.dave.android.base;

import java.io.InputStream;
import java.util.Properties;

import android.util.Log;

public abstract class PropertiesLoader extends FileLoader {
  private final static String LOG_TAG = PropertiesLoader.class.getName();

  protected PropertiesLoader () {
    super();
  }

  protected abstract void load (Properties properties);

  @Override
  protected final void load (InputStream stream) {
    Properties properties = loadProperties(stream);
    if (properties != null) load(properties);
  }
}
