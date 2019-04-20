package cc.mielke.dave.android.radio;

import java.util.ArrayList;
import java.io.File;

import android.util.Log;

public abstract class FilePlayer extends RadioPlayer {
  private final String LOG_TAG = getClass().getName();

  protected final CollectionLibrary collectionLibrary;

  protected FilePlayer (CollectionLibrary library) {
    super();
    collectionLibrary = library;
  }

  public final CollectionLibrary getLibrary () {
    return collectionLibrary;
  }

  private final static String[] audioExtensions = new String[] {
    ".mp3", ".mid"
  };

  protected static boolean hasAudioExtension (String name) {
    for (String extension : audioExtensions) {
      if (name.endsWith(extension)) return true;
    }

    return false;
  }

  private final ArrayList<File> collectionMembers = new ArrayList<>();
  private String collectionName = null;
  protected abstract void findMembers (File root);

  protected final void addMember (File member) {
    collectionMembers.add(member);
  }

  public final void setCollection (String name) {
    synchronized (collectionMembers) {
      collectionMembers.clear();
      collectionName = name;
    }
  }

  public final String getCollectionName () {
    synchronized (collectionMembers) {
      return collectionName;
    }
  }

  protected File nextFile () {
    synchronized (collectionMembers) {
      if (collectionMembers.isEmpty()) {
        String name = getCollectionName();
        if (name == null) return null;
        Log.i(LOG_TAG, String.format("loading collection: %s", name));

        File root = getLibrary().getRoot(name);
        if (root == null) return null;
        Log.i(LOG_TAG, String.format("collection root: %s: %s", name, root.getAbsolutePath()));

        findMembers(root);
        Log.i(LOG_TAG, String.format("collection size: %s: %d", name, collectionMembers.size()));
        if (collectionMembers.isEmpty()) return null;
      }

      return removeRandomElement(collectionMembers);
    }
  }

  @Override
  public final boolean play () {
    File file = nextFile();
    if (file == null) return false;

    logPlaying(file.getAbsolutePath());
    return true;
  }
}
