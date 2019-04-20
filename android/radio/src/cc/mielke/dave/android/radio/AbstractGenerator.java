package cc.mielke.dave.android.radio;

import java.util.List;
import java.util.ArrayList;
import java.io.File;

import android.util.Log;

public abstract class AbstractGenerator extends RadioComponent {
  private final static String LOG_TAG = AbstractGenerator.class.getName();

  protected final AbstractLibrary library;

  protected AbstractGenerator (AbstractLibrary library) {
    super();
    this.library = library;
  }

  public final AbstractLibrary getLibrary () {
    return library;
  }

  private final static String[] audioExtensions = new String[] {
    ".mp3"
  };

  protected final boolean hasAudioExtension (String name) {
    for (String extension : audioExtensions) {
      if (name.endsWith(extension)) return true;
    }

    return false;
  }

  private final ArrayList<File> members = new ArrayList<>();
  protected abstract void addMembers (File directory);

  protected final void addMember (File file) {
    members.add(file);
  }

  protected final File next (ArrayList<File> files) {
    int index = (int)Math.round(Math.floor((double)files.size() * Math.random()));
    return files.remove(index);
  }

  public File next () {
    if (members.isEmpty()) {
      File directory = getLibrary().getDirectory("Christian");
      Log.i(LOG_TAG, ("finding members: " + directory.getAbsolutePath()));

      addMembers(directory);
      Log.i(LOG_TAG, ("members found: " + members.size()));

      if (members.isEmpty()) return null;
    }

    return next(members);
  }
}
