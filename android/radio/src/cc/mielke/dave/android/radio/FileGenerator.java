package cc.mielke.dave.android.radio;

import java.util.List;
import java.util.ArrayList;
import java.io.File;

import android.util.Log;

public abstract class FileGenerator extends RadioComponent {
  private final String LOG_TAG = getClass().getName();

  protected final CollectionLibrary collectionLibrary;

  protected FileGenerator (CollectionLibrary library) {
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
  protected abstract void addMembers (File root);

  protected final void addMember (File member) {
    collectionMembers.add(member);
  }

  protected final File next (ArrayList<File> files) {
    int index = (int)Math.round(Math.floor((double)files.size() * Math.random()));
    return files.remove(index);
  }

  public File nextFile () {
    if (collectionMembers.isEmpty()) {
      File root = getLibrary().getRoot("Christian");
      Log.i(LOG_TAG, ("finding members: " + root.getAbsolutePath()));

      addMembers(root);
      Log.i(LOG_TAG, ("members found: " + collectionMembers.size()));

      if (collectionMembers.isEmpty()) return null;
    }

    return next(collectionMembers);
  }
}
