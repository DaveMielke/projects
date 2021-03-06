package cc.mielke.dave.android.radio;

import java.io.File;

import android.media.AudioAttributes;

public class MusicPlayer extends CollectionPlayer {
  public MusicPlayer () {
    super(getMusicLibrary());
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

  @Override
  protected final int getAudioContentType () {
    return AudioAttributes.CONTENT_TYPE_MUSIC;
  }
}
