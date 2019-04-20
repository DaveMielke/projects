package cc.mielke.dave.android.radio;

import java.io.File;

public class MusicGenerator extends FileGenerator {
  public MusicGenerator () {
    super(new MusicLibrary());
  }

  @Override
  protected final void addMembers (File root) {
    for (File file : root.listFiles()) {
      if (file.isDirectory()) {
        addMembers(file);
      } else if (hasAudioExtension(file.getName())) {
        addMember(file);
      }
    }
  }
}
