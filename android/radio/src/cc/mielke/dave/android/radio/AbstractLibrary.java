package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import java.io.File;

import android.util.Log;

public abstract class AbstractLibrary extends RadioComponent {
  private final static String LOG_TAG = AbstractLibrary.class.getName();

  protected AbstractLibrary () {
    super();
  }

  private final Map<String, File> nameToDirectory = new HashMap<>();

  protected final void addCollection (String name, String directory) {
    File file = new File(directory);

    if (!file.exists()) {
      Log.w(LOG_TAG, ("directory not found: " + file.getAbsolutePath()));
    } else if (!file.isDirectory()) {
      Log.w(LOG_TAG, ("not a directory: " + file.getAbsolutePath()));
    } else {
      synchronized (nameToDirectory) {
        nameToDirectory.put(name, file);
      }
    }
  }

  public final File getDirectory (String name) {
    synchronized (nameToDirectory) {
      return nameToDirectory.get(name);
    }
  }

  public final String[] getNames () {
    synchronized (nameToDirectory) {
      Set<String> names = nameToDirectory.keySet();
      return names.toArray(new String[names.size()]);
    }
  }
}
