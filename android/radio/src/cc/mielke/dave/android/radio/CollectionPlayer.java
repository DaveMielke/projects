package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.CollectionHelper;
import java.util.ArrayList;
import java.io.File;

import android.util.Log;

public abstract class CollectionPlayer extends FilePlayer {
  private final String LOG_TAG = CollectionPlayer.class.getName();

  protected final CollectionLibrary collectionLibrary;

  protected CollectionPlayer (CollectionLibrary library) {
    super();
    collectionLibrary = library;
  }

  public final CollectionLibrary getLibrary () {
    return collectionLibrary;
  }

  protected static boolean isAudioExtension (String extension) {
    return RadioParameters.AUDIO_EXTENSIONS.contains(extension.toLowerCase());
  }

  protected static boolean hasAudioExtension (File file) {
    String name = file.getName();
    int index = name.lastIndexOf('.');
    if (index < 1) return false;
    if (++index == name.length()) return false;
    return isAudioExtension(name.substring(index));
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

  private static class FileEntry {
    public final File file;
    public final int audioContentType;
    public final long time = getCurrentTime();

    public FileEntry (File file, int audioContentType) {
      this.file = file;
      this.audioContentType = audioContentType;
    }
  }

  private final static ArrayList<FileEntry> fileList = new ArrayList<>();
  private static int currentFile = fileList.size();
  protected abstract int getAudioContentType ();

  protected File nextFile () {
    synchronized (collectionMembers) {
      if (collectionMembers.isEmpty()) {
        String name = getCollectionName();
        if (name == null) return null;

        if (RadioParameters.LOG_COLLECTION_PLAYER) {
          Log.d(LOG_TAG, String.format("loading collection: %s", name));
        }

        CollectionLibrary library = getLibrary();
        if (library == null) return null;

        File root = library.getRoot(name);
        if (root == null) return null;

        if (RadioParameters.LOG_COLLECTION_PLAYER) {
          Log.d(LOG_TAG, String.format("collection root: %s: %s", name, root.getAbsolutePath()));
        }

        findMembers(root);

        if (RadioParameters.LOG_COLLECTION_PLAYER) {
          Log.d(LOG_TAG, String.format("collection size: %s: %d", name, collectionMembers.size()));
        }

        if (collectionMembers.isEmpty()) return null;
      }

      return CollectionHelper.removeRandomElement(collectionMembers);
    }
  }

  private final FileEntry nextFileEntry () {
    synchronized (collectionMembers) {
      if (currentFile == fileList.size()) {
        File file = nextFile();
        if (file == null) return null;

        FileEntry next = new FileEntry(file, getAudioContentType());
        fileList.add(next);
      }

      return fileList.get(currentFile++);
    }
  }

  @Override
  public final boolean play () {
    FileEntry next = nextFileEntry();
    if (next == null) return false;
    return play(next.file, next.audioContentType);
  }

  @Override
  protected final boolean actionNext () {
    synchronized (AUDIO_LOCK) {
      stop();
      return true;
    }
  }

  @Override
  protected final boolean actionPrevious () {
    synchronized (AUDIO_LOCK) {
      if (currentFile < 1) return false;
      currentFile -= 1;

      if (currentFile > 0) {
        if (getPosition() < RadioParameters.FILE_PREVIOUS_THRESHOLD) {
          currentFile -= 1;
        }
      }

      stop();
      return true;
    }
  }
}
