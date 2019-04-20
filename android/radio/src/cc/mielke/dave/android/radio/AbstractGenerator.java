package cc.mielke.dave.android.radio;

import java.util.List;
import java.util.ArrayList;
import java.io.File;

public abstract class AbstractGenerator extends RadioComponent {
  protected final AbstractLibrary library;

  protected AbstractGenerator (AbstractLibrary library) {
    super();
    this.library = library;
  }

  public final AbstractLibrary getLibrary () {
    return library;
  }

  protected abstract void addMembers (List<File> members, File directory);
}
