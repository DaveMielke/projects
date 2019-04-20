package cc.mielke.dave.android.radio;

import java.util.List;
import java.io.File;

public class MusicGenerator extends AbstractGenerator {
  public MusicGenerator () {
    super(new MusicLibrary());
  }

  @Override
  protected final void addMembers (List members, File directory) {
    String[] extensions = new String[] {
      ".mp3"
    };

    for (File file : directory.listFiles()) {
      if (file.isDirectory()) {
        addMembers(members, file);
      } else {
        String name = file.getName();

        for (String extension : extensions) {
          if (name.endsWith(extension)) {
            members.add(file);
            break;
          }
        }
      }
    }
  }
}
