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

  protected static String[] getKeys (JSONObject object) {
    String[] keys = new String[object.length()];
    Iterator<String> iterator = object.keys();
    int index = 0;

    while (iterator.hasNext()) {
      keys[index++] = iterator.next();
    }

    return keys;
  }

  protected static void logUnhandledKeys (JSONObject object, CharSequence label) {
    Iterator<String> iterator = object.keys();

    while (iterator.hasNext()) {
      Log.w(LOG_TAG, ("key not handled: " + iterator.next() + ": " + label));
    }
  }

  private static String keyToString (Object key) {
    if (key instanceof String) return "\"" + key + "\"";
    if (key instanceof Integer) return "[" + key + "]";
    return null;
  }

  private static <T> T getVerified (Object value, Class<? extends T> type, Object key, CharSequence label) {
    if (value != null) {
      if (type.isInstance(value)) return (T)value;

      Log.w(LOG_TAG,
        String.format(
          "not a %s: %s: %s",
          type.getSimpleName(), keyToString(key), label
        )
      );
    }

    return null;
  }

  private static JSONObject getVerifiedObject (Object value, Object key, CharSequence label) {
    return getVerified(value, JSONObject.class, key, label);
  }

  private static JSONArray getVerifiedArray (Object value, Object key, CharSequence label) {
    return getVerified(value, JSONArray.class, key, label);
  }

  private static String getVerifiedString (Object value, Object key, CharSequence label) {
    return getVerified(value, String.class, key, label);
  }

  private static Boolean getVerifiedBoolean (Object value, Object key, CharSequence label) {
    return getVerified(value, Boolean.class, key, label);
  }

  private static Integer getVerifiedInteger (Object value, Object key, CharSequence label) {
    return getVerified(value, Integer.class, key, label);
  }

  private static Long getVerifiedLong (Object value, Object key, CharSequence label) {
    return getVerified(value, Long.class, key, label);
  }

  private static Double getVerifiedDouble (Object value, Object key, CharSequence label) {
    return getVerified(value, Double.class, key, label);
  }

  private static Object getValue (JSONObject object, String key) {
    return object.remove(key);
  }

  protected static JSONObject getObject (JSONObject object, String key, CharSequence label) {
    return getVerifiedObject(getValue(object, key), key, label);
  }

  protected static JSONArray getArray (JSONObject object, String key, CharSequence label) {
    return getVerifiedArray(getValue(object, key), key, label);
  }

  protected static String getString (JSONObject object, String key, CharSequence label) {
    return getVerifiedString(getValue(object, key), key, label);
  }

  protected static boolean getBoolean (JSONObject object, String key, CharSequence label) {
    Boolean value = getVerifiedBoolean(getValue(object, key), key, label);
    if (value == null) return false;
    return value;
  }

  protected static int getInteger (JSONObject object, String key, CharSequence label) {
    Integer value = getVerifiedInteger(getValue(object, key), key, label);
    if (value == null) return 0;
    return value;
  }

  protected static long getLong (JSONObject object, String key, CharSequence label) {
    Long value = getVerifiedLong(getValue(object, key), key, label);
    if (value == null) return 0;
    return value;
  }

  protected static double getDouble (JSONObject object, String key, CharSequence label) {
    Double value = getVerifiedDouble(getValue(object, key), key, label);
    if (value == null) return 0d;
    return value;
  }

  private static Object getValue (JSONArray array, int index) {
    return array.opt(index);
  }

  protected static JSONObject getObject (JSONArray array, int index, CharSequence label) {
    return getVerifiedObject(getValue(array, index), index, label);
  }

  protected static JSONArray getArray (JSONArray array, int index, CharSequence label) {
    return getVerifiedArray(getValue(array, index), index, label);
  }

  protected static String getString (JSONArray array, int index, CharSequence label) {
    return getVerifiedString(getValue(array, index), index, label);
  }

  protected static boolean getBoolean (JSONArray array, int index, CharSequence label) {
    Boolean value = getVerifiedBoolean(getValue(array, index), index, label);
    if (value == null) return false;
    return value;
  }

  protected static int getInteger (JSONArray array, int index, CharSequence label) {
    Integer value = getVerifiedInteger(getValue(array, index), index, label);
    if (value == null) return 0;
    return value;
  }

  protected static long getLong (JSONArray array, int index, CharSequence label) {
    Long value = getVerifiedLong(getValue(array, index), index, label);
    if (value == null) return 0;
    return value;
  }

  protected static double getDouble (JSONArray array, int index, CharSequence label) {
    Double value = getVerifiedDouble(getValue(array, index), index, label);
    if (value == null) return 0d;
    return value;
  }
}
