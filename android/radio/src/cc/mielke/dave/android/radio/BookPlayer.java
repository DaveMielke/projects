package cc.mielke.dave.android.radio;

import java.util.ArrayList;
import java.util.Comparator;
import java.io.File;

import java.util.Set;
import java.util.HashSet;

public class BookPlayer extends FilePlayer {
  public BookPlayer () {
    super(new BookLibrary());
    setCollection("Bible");
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
            if (!hasAudioExtension(file.getName())) continue;
            bookFiles.add(file);
          }

          if (!bookFiles.isEmpty()) {
            bookFiles.sort(
              new Comparator<File>() {
                @Override
                public int compare (File file1, File file2) {
                  return file1.getAbsolutePath().compareTo(file2.getAbsolutePath());
                }
              }
            );

            break;
          }
        }
      }

      return bookFiles.remove(0);
    }
  }
}
