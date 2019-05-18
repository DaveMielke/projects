package cc.mielke.dave.android.base;

import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;

import java.io.IOException;
import java.io.FileNotFoundException;

import android.util.Log;
import android.content.Context;
import android.content.res.AssetManager;

public abstract class FileLoader extends BaseComponent {
  private final static String LOG_TAG = FileLoader.class.getName();

  protected FileLoader () {
    super();
  }

  protected abstract void load (InputStream stream, String path);

  private final void load (File file) {
    if (file.exists()) {
      String path = file.getAbsolutePath();

      if (!file.isFile()) {
        Log.w(LOG_TAG, ("not a file: " + path));
      } else if (!file.canRead()) {
        Log.w(LOG_TAG, ("file not readable: " + path));
      } else {
        try {
          InputStream stream = new FileInputStream(file);
          try {
            load(stream, path);
          } finally {
            try {
              stream.close();
            } catch (IOException exception) {
              Log.w(LOG_TAG, ("file input stream close error: " + exception.getMessage()));
            }
          }
        } catch (IOException exception) {
          Log.w(LOG_TAG, ("file open error: " + exception.getMessage()));
        }
      }
    }
  }

  private final void load (File directory, String path) {
    if (directory != null) load(new File(directory, path));
  }

  private final void load (AssetManager assets, String path) {
    try {
      InputStream stream = assets.open(path);
      try {
        load(stream, path);
      } finally {
        try {
          stream.close();
        } catch (IOException exception) {
          Log.w(LOG_TAG, ("asset input stream close error: " + exception.getMessage()));
        }
      }
    } catch (FileNotFoundException exception) {
      // ignore - opening an asset is the only way to test its existence
    } catch (IOException exception) {
      Log.w(LOG_TAG, ("asset open error: " + exception.getMessage()));
    }
  }

  public final void load (String path) {
    Context context = getContext();

    load(context.getFilesDir(), path);
    load(getExternalStorageDirectory(), path);
    load(context.getAssets(), path);
  }
}
