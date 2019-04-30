package cc.mielke.dave.android.radio;

import android.util.Log;

import java.io.File;
import android.net.Uri;

public abstract class FilePlayer extends UriPlayer {
  private final static String LOG_TAG = FilePlayer.class.getName();

  protected FilePlayer () {
    super();
  }

  protected final boolean play (File file, int audioContentType) {
    if (file == null) return false;

    if (!file.exists()) {
      Log.w(LOG_TAG, ("file not found: " + file.getAbsolutePath()));
      return false;
    }

    if (!file.isFile()) {
      Log.w(LOG_TAG, ("not a file: " + file.getAbsolutePath()));
      return false;
    }

    if (!file.canRead()) {
      Log.w(LOG_TAG, ("file not readable: " + file.getAbsolutePath()));
      return false;
    }

    return play(Uri.fromFile(file), audioContentType);
  }
}
