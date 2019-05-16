package cc.mielke.dave.android.base;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;
import java.util.Iterator;

import android.util.Log;

public abstract class JSONLoader extends StringLoader {
  private final static String LOG_TAG = JSONLoader.class.getName();

  protected JSONLoader () {
    super();
  }

  protected final String[] getKeys (JSONObject object) {
    String[] keys = new String[object.length()];
    Iterator<String> iterator = object.keys();
    int index = 0;

    while (iterator.hasNext()) {
      keys[index++] = iterator.next();
    }

    return keys;
  }

  protected final void logUnhandledKeys (JSONObject object, CharSequence label) {
    Iterator<String> iterator = object.keys();

    while (iterator.hasNext()) {
      Log.w(LOG_TAG, ("key not handled: " + iterator.next() + ": " + label));
    }
  }

  private final void logUnexpectedType (String type, String key, CharSequence label) {
    StringBuilder log = new StringBuilder();

    log.append("not ");
    log.append(type);

    log.append(": ");
    log.append(key);

    log.append(": ");
    log.append(label);

    Log.w(LOG_TAG, log.toString());
  }

  private final Object getValue (JSONObject object, String key) {
    return object.remove(key);
  }

  protected final JSONObject getObject (JSONObject object, String key, CharSequence label) {
    Object value = getValue(object, key);

    if (value != null) {
      if (value instanceof JSONObject) return (JSONObject)value;
      logUnexpectedType("object", key, label);
    }

    return null;
  }

  protected final JSONArray getArray (JSONObject object, String key, CharSequence label) {
    Object value = getValue(object, key);

    if (value != null) {
      if (value instanceof JSONArray) return (JSONArray)value;
      logUnexpectedType("array", key, label);
    }

    return null;
  }

  protected final String getString (JSONObject object, String key, CharSequence label) {
    Object value = getValue(object, key);

    if (value != null) {
      if (value instanceof String) return (String)value;
      logUnexpectedType("string", key, label);
    }

    return null;
  }

  protected final boolean getBoolean (JSONObject object, String key, CharSequence label) {
    Object value = getValue(object, key);

    if (value != null) {
      if (value instanceof Boolean) return (Boolean)value;
      logUnexpectedType("boolean", key, label);
    }

    return false;
  }

  protected final int getInteger (JSONObject object, String key, CharSequence label) {
    Object value = getValue(object, key);

    if (value != null) {
      if (value instanceof Integer) return (Integer)value;
      logUnexpectedType("integer", key, label);
    }

    return 0;
  }

  protected final long getLong (JSONObject object, String key, CharSequence label) {
    Object value = getValue(object, key);

    if (value != null) {
      if (value instanceof Long) return (Long)value;
      logUnexpectedType("long", key, label);
    }

    return 0L;
  }

  protected final double getDouble (JSONObject object, String key, CharSequence label) {
    Object value = getValue(object, key);

    if (value != null) {
      if (value instanceof Double) return (Double)value;
      logUnexpectedType("double", key, label);
    }

    return 0d;
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
