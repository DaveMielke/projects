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

  protected abstract void loadFromInputStream (InputStream stream, String name);

  private final void loadFromFile (File file) {
    if (file.exists()) {
      if (file.isDirectory()) {
        String[] names = file.list();

        if (names != null) {
          for (String name : names) {
            loadFromFile(new File(file, name));
          }
        }
      } else if (file.isFile()) {
        try {
          InputStream stream = new FileInputStream(file);
          try {
            loadFromInputStream(stream, file.getName());
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

  private final void loadFromFile (File directory, String name) {
    if (directory != null) loadFromFile(new File(directory, name));
  }

  private final void loadFromAsset (AssetManager assets, String path) {
    try {
      String[] names = assets.list(path);

      if ((names != null) && (names.length > 0)) {
        for (String name : names) {
          loadFromAsset(assets, (path + File.separatorChar + name));
        }
      } else {
        try {
          InputStream stream = assets.open(path);
          try {
            loadFromInputStream(stream, path.substring(path.lastIndexOf(File.separatorChar) + 1));
          } finally {
            try {
              stream.close();
            } catch (IOException exception) {
              Log.w(LOG_TAG, ("asset input stream close error: " + exception.getMessage()));
            }
          }
        } catch (FileNotFoundException exception) {
          // ignore - opening an asset is the only way to test its existence
        }
      }
    } catch (IOException exception) {
      Log.w(LOG_TAG, ("asset open error: " + exception.getMessage()));
    }
  }

  public final void loadFromFile (String name) {
    Context context = getContext();

    loadFromFile(context.getFilesDir(), name);
    loadFromFile(getExternalStorageDirectory(), name);
    loadFromAsset(context.getAssets(), name);
  }
}
