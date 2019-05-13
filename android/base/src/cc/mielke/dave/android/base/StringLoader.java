package cc.mielke.dave.android.base;

import java.io.IOException;
import java.io.Reader;

import android.util.Log;

public abstract class StringLoader extends CharactersLoader {
  private final static String LOG_TAG = StringLoader.class.getName();

  protected StringLoader () {
    super();
  }

  protected abstract void loadFromString (String string, String name);

  @Override
  protected final void loadFromReader (Reader reader, String name) {
    StringBuilder characters = new StringBuilder();

    try {
      char[] buffer = new char[0X1000];
      int count;

      while ((count = reader.read(buffer)) != -1) {
        characters.append(buffer, 0, count);
      }

      loadFromString(characters.toString(), name);
    } catch (IOException exception) {
      Log.w(LOG_TAG, ("input error: " + exception.getMessage()));
    }
  }
}
