package cc.mielke.dave.android.radio;

import java.io.File;

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
}
