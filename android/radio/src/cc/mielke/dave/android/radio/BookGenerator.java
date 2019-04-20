package cc.mielke.dave.android.radio;

import java.io.File;

public class BookGenerator extends FileGenerator {
  public BookGenerator () {
    super(new BookLibrary());
  }

  @Override
  protected final void addMembers (File root) {
    for (File file : root.listFiles()) {
      if (file.isDirectory()) addMember(file);
    }
  }
}
