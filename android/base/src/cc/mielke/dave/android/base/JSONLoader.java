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

  protected final String[] getNames (JSONObject object) {
    String[] names = new String[object.length()];
    Iterator<String> iterator = object.keys();
    int index = 0;

    while (iterator.hasNext()) {
      names[index++] = iterator.next();
    }

    return names;
  }

  private final void logUnexpectedType (String type, String key, CharSequence label) {
    StringBuilder log = new StringBuilder();

    log.append("not a ");
    log.append(type);

    log.append(": ");
    log.append(key);

    log.append(": ");
    log.append(label);

    Log.w(LOG_TAG, log.toString());
  }

  protected final String getString (JSONObject object, String key, CharSequence label) {
    Object value = object.remove(key);

    if (value != null) {
      if (value instanceof String) return (String)value;
      logUnexpectedType("string", key, label);
    }

    return null;
  }

  protected final boolean getBoolean (JSONObject object, String key, CharSequence label) {
    Object value = object.remove(key);

    if (value != null) {
      if (value instanceof Boolean) return (Boolean)value;
      logUnexpectedType("boolean", key, label);
    }

    return false;
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
