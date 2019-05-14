package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import java.io.File;

import cc.mielke.dave.android.base.JSONLoader;
import org.json.JSONObject;
import org.json.JSONArray;
import java.util.Iterator;

import android.util.Log;

public abstract class CollectionLibrary extends RadioComponent {
  private final static String LOG_TAG = CollectionLibrary.class.getName();

  protected final void addCollection (String name, String directory) {
    synchronized (nameToRoot) {
      if (nameToRoot.get(name) != null) {
        Log.w(LOG_TAG, ("collection already defined: " + name));
      } else if ((directory == null) || directory.isEmpty()) {
        Log.w(LOG_TAG, ("collectiin directory not specified: " + name));
      } else {
        File root = new File(directory);

        if (!root.exists()) {
          Log.w(LOG_TAG, String.format("directory not found: %s: %s", name, root.getAbsolutePath()));
        } else if (!root.isDirectory()) {
          Log.w(LOG_TAG, String.format("not a directory: %s: %s", name, root.getAbsolutePath()));
        } else {
          nameToRoot.put(name, root);
        }
      }
    }
  }

  private final void addCollections (String type) {
    new JSONLoader() {
      @Override
      public void load (JSONObject object, String name) {
        Iterator<String> iterator = object.keys();

        while (iterator.hasNext()) {
          String title = iterator.next();
          addCollection(title, object.optString(title, null));
        }
      }
    }.load(type);
  }

  protected CollectionLibrary (String type) {
    super();
    addCollections(type);
  }

  private final Map<String, File> nameToRoot = new HashMap<>();

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
