package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;
import java.io.File;

import android.util.Log;

public abstract class CollectionLibrary extends RadioComponent {
  private final static String LOG_TAG = CollectionLibrary.class.getName();

  private final void addCollections (String type) {
    File directory = RadioApplication.getExternalDirectory();

    if (directory != null) {
      Properties properties = loadProperties(new File(directory, type));

      if (properties != null) {
        for (String name : properties.stringPropertyNames()) {
          String path = properties.getProperty(name, null);
          if (path == null) continue;
          if (path.isEmpty()) continue;
          addCollection(name, path);
        }
      }
    }
  }

  protected CollectionLibrary (String type) {
    super();
    addCollections(type);
  }

  private final Map<String, File> nameToRoot = new HashMap<>();

  protected final void addCollection (String name, String directory) {
    File root = new File(directory);

    if (!root.exists()) {
      Log.w(LOG_TAG, ("directory not found: " + root.getAbsolutePath()));
    } else if (!root.isDirectory()) {
      Log.w(LOG_TAG, ("not a directory: " + root.getAbsolutePath()));
    } else {
      synchronized (nameToRoot) {
        nameToRoot.put(name, root);
      }
    }
  }

  public final File getRoot (String name) {
    synchronized (nameToRoot) {
      return nameToRoot.get(name);
    }
  }

  public final String[] getNames () {
    synchronized (nameToRoot) {
      Set<String> names = nameToRoot.keySet();
      return names.toArray(new String[names.size()]);
    }
  }
}
