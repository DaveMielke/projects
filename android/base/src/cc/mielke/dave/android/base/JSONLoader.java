package cc.mielke.dave.android.base;

import org.json.JSONObject;
import org.json.JSONException;

import android.util.Log;

public abstract class JSONLoader extends StringLoader {
  private final static String LOG_TAG = JSONLoader.class.getName();

  protected JSONLoader () {
    super();
  }

  protected abstract void loadFromJSON (JSONObject json, String name);

  @Override
  protected final void loadFromString (String string, String name) {
    try {
      loadFromJSON(new JSONObject(string), name);
    } catch (JSONException exception) {
      Log.w(LOG_TAG, ("JSON read error: " + exception.getMessage()));
    }
  }
}
