package cc.mielke.dave.android.base;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

import java.io.InputStream;
import java.io.Reader;
import java.io.InputStreamReader;

import android.util.Log;

public abstract class CharactersLoader extends FileLoader {
  private final static String LOG_TAG = CharactersLoader.class.getName();

  protected CharactersLoader () {
    super();
  }

  protected abstract void load (Reader reader, String path);

  @Override
  protected final void load (InputStream stream, String path) {
    String encoding = "UTF-8";

    try {
      Reader reader = new InputStreamReader(stream, encoding);
      try {
        load(reader, path);
      } finally {
        try {
          reader.close();
        } catch (IOException exception) {
          Log.w(LOG_TAG, ("reader close error: " + exception.getMessage()));
        }
      }
    } catch (UnsupportedEncodingException exception) {
      Log.e(LOG_TAG, ("unsupported character encoding" + encoding));
    }
  }
}
