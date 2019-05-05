package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;

import java.util.Collections;
import java.util.ArrayList;
import java.util.Comparator;
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
    Comparator<File> comparator =
      new Comparator<File>() {
        @Override
        public int compare (File file1, File file2) {
          return file1.getAbsolutePath().compareTo(file2.getAbsolutePath());
        }
      };

    if (ApiTests.HAVE_ArrayList_sort) {
      files.sort(comparator);
    } else {
      Collections.sort(files, comparator);
    }
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

  private final ArrayList<FileEntry> fileList = new ArrayList<>();
  private int currentFile = fileList.size();
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

      return removeRandomElement(collectionMembers);
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
}
