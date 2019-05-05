package cc.mielke.dave.android.radio;

import java.util.ArrayList;
import java.io.File;

import java.util.Set;
import java.util.HashSet;

import android.media.AudioAttributes;

public class BookPlayer extends CollectionPlayer {
  public BookPlayer () {
    super(getBookLibrary());
  }

  @Override
  protected final void findMembers (File root) {
    File[] files = root.listFiles();

    if (files != null) {
      for (File file : files) {
        if (file.isDirectory()) addMember(file);
      }
    }
  }

  private final ArrayList<File> bookFiles = new ArrayList<>();

  @Override
  protected File nextFile () {
    synchronized (bookFiles) {
      if (bookFiles.isEmpty()) {
        Set<File> encountered = new HashSet<>();

        while (true) {
          File book = super.nextFile();
          if (book == null) return null;

          if (encountered.contains(book)) return null;
          encountered.add(book);

          for (File file : book.listFiles()) {
            if (!file.isFile()) continue;
            if (!hasAudioExtension(file)) continue;
            bookFiles.add(file);
          }

          if (!bookFiles.isEmpty()) {
            sortByPath(bookFiles);
            break;
          }
        }
      }

      return bookFiles.remove(0);
    }
  }

  @Override
  protected final int getAudioContentType () {
    return AudioAttributes.CONTENT_TYPE_SPEECH;
  }
}
