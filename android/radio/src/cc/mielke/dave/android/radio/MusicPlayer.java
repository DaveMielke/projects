package cc.mielke.dave.android.radio;

import java.io.File;

public class MusicPlayer extends FilePlayer {
  public MusicPlayer () {
    super(new MusicLibrary());
    setCollection("Portraits");
  }

  @Override
  protected final void findMembers (File root) {
    File[] files = root.listFiles();

    if (files != null) {
      for (File file : files) {
        if (file.isDirectory()) {
          findMembers(file);
        } else if (hasAudioExtension(file.getName())) {
          addMember(file);
        }
      }
    }
  }
}
