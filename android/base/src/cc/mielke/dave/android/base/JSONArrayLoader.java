package cc.mielke.dave.android.base;

import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

public abstract class JSONArrayLoader extends JSONLoader {
  private final static String LOG_TAG = JSONArrayLoader.class.getName();

  protected JSONArrayLoader () {
    super();
  }

  protected abstract void load (JSONArray root, String path);

  @Override
  protected final void load (String string, String path) {
    try {
      load(new JSONArray(string), path);
    } catch (JSONException exception) {
      Log.w(LOG_TAG, ("JSON array read error: " + exception.getMessage()));
    }
  }
}
