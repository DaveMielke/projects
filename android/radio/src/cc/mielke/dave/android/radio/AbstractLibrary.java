package cc.mielke.dave.android.radio;

import java.util.Map;
import java.util.HashMap;
import java.io.File;

import android.util.Log;

public abstract class AbstractLibrary {
  private final static String LOG_TAG = AbstractLibrary.class.getName();

  protected AbstractLibrary () {
    super();
  }

  private final Map<String, File> bookDirectories = new HashMap<>();

  protected final void add (String name, String directory) {
    File file = new File(directory);

    if (!file.exists()) {
      Log.w(LOG_TAG, ("directory not found: " + file.getAbsolutePath()));
    } else if (!file.isDirectory()) {
      Log.w(LOG_TAG, ("not a directory: " + file.getAbsolutePath()));
    } else {
      synchronized (bookDirectories) {
        bookDirectories.put(name, file);
      }
    }
  }

  public final File get (String name) {
    synchronized (bookDirectories) {
      return bookDirectories.get(name);
    }
  }
}
