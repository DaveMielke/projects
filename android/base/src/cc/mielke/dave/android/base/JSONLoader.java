package cc.mielke.dave.android.base;

import org.json.JSONObject;
import org.json.JSONException;
import java.util.Iterator;

import android.util.Log;

public abstract class JSONLoader extends StringLoader {
  private final static String LOG_TAG = JSONLoader.class.getName();

  protected JSONLoader () {
    super();
  }

  protected final String getString (JSONObject object, String key, CharSequence label) {
    Object string = object.remove(key);
    if (string == null) return null;
    if (string instanceof String) return (String)string;

    Log.w(LOG_TAG, ("\"" + key + "\" is not a string: " + label));
    return null;
  }

  protected final void logUnhandledKeys (JSONObject object, CharSequence label) {
    Iterator<String> iterator = object.keys();

    while (iterator.hasNext()) {
      Log.w(LOG_TAG, ("key has not been handled: " + iterator.next() + ": " + label));
    }
  }

  protected abstract void load (JSONObject root, String name);

  @Override
  protected final void load (String string, String name) {
    try {
      load(new JSONObject(string), name);
    } catch (JSONException exception) {
      Log.w(LOG_TAG, ("JSON read error: " + exception.getMessage()));
    }
  }
}
