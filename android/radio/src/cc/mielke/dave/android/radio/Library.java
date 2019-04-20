package cc.mielke.dave.android.radio;

import java.util.Map;
import java.util.HashMap;
import java.io.File;

public abstract class Library {
  protected Library () {
    super();
  }

  private final Map<String, File> bookDirectories = new HashMap<>();

  protected final void add (String name, String directory) {
    File file = new File(directory);

    synchronized (bookDirectories) {
      bookDirectories.put(name, file);
    }
  }

  public final File get (String name) {
    synchronized (bookDirectories) {
      return bookDirectories.get(name);
    }
  }
}
