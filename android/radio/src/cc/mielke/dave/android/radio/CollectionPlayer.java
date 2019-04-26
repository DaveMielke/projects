package cc.mielke.dave.android.radio;

import java.util.ArrayList;
import java.util.Comparator;
import java.io.File;

import android.util.Log;

public abstract class CollectionPlayer extends FilePlayer {
  private final String LOG_TAG = getClass().getName();

  protected final CollectionLibrary collectionLibrary;

  protected CollectionPlayer (RadioProgram program, CollectionLibrary library) {
    super(program);
    collectionLibrary = library;
  }

  public final CollectionLibrary getLibrary () {
    return collectionLibrary;
  }

  protected static boolean hasAudioExtension (String name) {
    for (String extension : RadioParameters.AUDIO_EXTENSIONS) {
      if (name.endsWith(extension)) return true;
    }

    return false;
  }

  protected static boolean hasAudioExtension (File file) {
    return hasAudioExtension(file.getName());
  }

  protected static void sortByPath (ArrayList<File> files) {
    files.sort(
      new Comparator<File>() {
        @Override
        public int compare (File file1, File file2) {
          return file1.getAbsolutePath().compareTo(file2.getAbsolutePath());
        }
      }
    );
  }

  private final ArrayList<File> collectionMembers = new ArrayList<>();
  private String collectionName = null;
  protected abstract void findMembers (File root);

  protected final void addMember (File member) {
    collectionMembers.add(member);
  }

  public final CollectionPlayer setCollection (String name) {
    synchronized (collectionMembers) {
      collectionMembers.clear();
      collectionName = name;
    }

    return this;
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

        CollectionLibrary library = getLibrary();
        if (library == null) return null;

        File root = library.getRoot(name);
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
    return play(file);
  }
}
