package cc.mielke.dave.android.base;

import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.IOException;

import android.util.Log;
import android.content.Context;
import android.content.res.AssetManager;

public abstract class FileLoader extends BaseComponent {
  private final static String LOG_TAG = FileLoader.class.getName();

  protected FileLoader () {
    super();
  }

  protected abstract void load (InputStream stream);

  private final void load (File file) {
    if (file.exists()) {
      if (file.isDirectory()) {
        String[] names = file.list();

        if (names != null) {
          for (String name : names) {
            load(new File(file, name));
          }
        }
      } else {
        Log.d(LOG_TAG, ("loading file: " + file.getAbsolutePath()));

        try {
          load(new FileInputStream(file));
        } catch (IOException exception) {
          Log.w(LOG_TAG, ("file input error: " + exception.getMessage()));
        }
      }
    }
  }

  private final void load (File directory, String name) {
    if (directory != null) load(new File(directory, name));
  }

  private final void load (AssetManager assets, String path) {
    try {
      String[] names = assets.list(path);

      if ((names != null) && (names.length > 0)) {
        for (String name : names) {
          load(assets, new File(path, name).getPath());
        }
      } else {
        Log.d(LOG_TAG, ("loading asset: " + path));
        load(assets.open(path));
      }
    } catch (IOException exception) {
      Log.w(LOG_TAG, ("asset error: " + exception.getMessage()));
    }
  }

  public final void load (String name) {
    Context context = getContext();

    load(context.getFilesDir(), name);
    load(getExternalStorageDirectory(), name);
    load(context.getAssets(), name);
  }
}
