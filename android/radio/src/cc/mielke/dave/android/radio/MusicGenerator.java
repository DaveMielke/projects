package cc.mielke.dave.android.radio;

import java.io.File;

public class MusicGenerator extends AbstractGenerator {
  public MusicGenerator () {
    super(new MusicLibrary());
  }

  @Override
  protected final void addMembers (File directory) {
    for (File file : directory.listFiles()) {
      if (file.isDirectory()) {
        addMembers(file);
      } else if (hasAudioExtension(file.getName())) {
        addMember(file);
      }
    }
  }
}
