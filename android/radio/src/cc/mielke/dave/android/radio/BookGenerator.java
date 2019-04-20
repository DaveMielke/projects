package cc.mielke.dave.android.radio;

import java.io.File;

public class BookGenerator extends AbstractGenerator {
  public BookGenerator () {
    super(new BookLibrary());
  }

  @Override
  protected final void addMembers (File directory) {
    for (File file : directory.listFiles()) {
      if (file.isDirectory()) addMember(file);
    }
  }
}
