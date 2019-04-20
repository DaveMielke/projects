package cc.mielke.dave.android.radio;

import java.io.File;

public class MusicPlayer extends CollectionPlayer {
  public MusicPlayer () {
    super(new MusicLibrary());
  }

  @Override
  protected final void findMembers (File root) {
    File[] files = root.listFiles();

    if (files != null) {
      for (File file : files) {
        if (file.isDirectory()) {
          findMembers(file);
        } else if (hasAudioExtension(file)) {
          addMember(file);
        }
      }
    }
  }
}
