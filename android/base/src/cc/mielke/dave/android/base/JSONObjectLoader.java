package cc.mielke.dave.android.base;

import org.json.JSONObject;
import org.json.JSONException;

import android.util.Log;

public abstract class JSONObjectLoader extends JSONLoader {
  private final static String LOG_TAG = JSONObjectLoader.class.getName();

  protected JSONObjectLoader () {
    super();
  }

  protected abstract void load (JSONObject root, String name);

  @Override
  protected final void load (String string, String name) {
    try {
      load(new JSONObject(string), name);
    } catch (JSONException exception) {
      Log.w(LOG_TAG, ("JSON object read error: " + exception.getMessage()));
    }
  }
}
