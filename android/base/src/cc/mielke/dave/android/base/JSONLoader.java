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

  protected static void jsonLogProblem (String problem) {
    Log.w(LOG_TAG, ("JSON problem: " + problem));
  }

  protected static void jsonLogProblem (String format, Object... arguments) {
    jsonLogProblem(String.format(format, arguments));
  }

  protected static String[] jsonGetKeys (JSONObject object) {
    String[] keys = new String[object.length()];
    Iterator<String> iterator = object.keys();
    int index = 0;

    while (iterator.hasNext()) {
      keys[index++] = iterator.next();
    }

    return keys;
  }

  protected static void jsonLogUnhandledKeys (JSONObject object, CharSequence label) {
    Iterator<String> iterator = object.keys();

    while (iterator.hasNext()) {
      jsonLogProblem(
        "key not handled: %s: %s",
        jsonKeyToString(iterator.next()), label
      );
    }
  }

  private static String jsonKeyToString (Object key) {
    if (key instanceof String) return "\"" + key + "\"";
    if (key instanceof Integer) return "[" + key + "]";
    return null;
  }

  private static <T> T jsonGetVerified (Object value, Class<? extends T> type, Object key, CharSequence label) {
    if (value != null) {
      if (type.isInstance(value)) return (T)value;

      String expected = type.getSimpleName();
      String found = (value == JSONObject.NULL)? "null": value.getClass().getSimpleName();

      jsonLogProblem(
        "%s expected but %s found: %s: %s",
        expected, found, jsonKeyToString(key), label
      );
    }

    return null;
  }

  private static JSONObject jsonGetVerifiedObject (Object value, Object key, CharSequence label) {
    return jsonGetVerified(value, JSONObject.class, key, label);
  }

  private static JSONArray jsonGetVerifiedArray (Object value, Object key, CharSequence label) {
    return jsonGetVerified(value, JSONArray.class, key, label);
  }

  private static String jsonGetVerifiedString (Object value, Object key, CharSequence label) {
    return jsonGetVerified(value, String.class, key, label);
  }

  private static Boolean jsonGetVerifiedBoolean (Object value, Object key, CharSequence label) {
    return jsonGetVerified(value, Boolean.class, key, label);
  }

  private static Integer jsonGetVerifiedInteger (Object value, Object key, CharSequence label) {
    return jsonGetVerified(value, Integer.class, key, label);
  }

  private static Long jsonGetVerifiedLong (Object value, Object key, CharSequence label) {
    return jsonGetVerified(value, Long.class, key, label);
  }

  private static Double jsonGetVerifiedDouble (Object value, Object key, CharSequence label) {
    return jsonGetVerified(value, Double.class, key, label);
  }

  private static Object jsonGetValue (JSONObject object, String key) {
    return object.remove(key);
  }

  protected static JSONObject jsonGetObject (JSONObject object, String key, CharSequence label) {
    return jsonGetVerifiedObject(jsonGetValue(object, key), key, label);
  }

  protected static JSONArray jsonGetArray (JSONObject object, String key, CharSequence label) {
    return jsonGetVerifiedArray(jsonGetValue(object, key), key, label);
  }

  protected static String jsonGetString (JSONObject object, String key, CharSequence label) {
    return jsonGetVerifiedString(jsonGetValue(object, key), key, label);
  }

  protected static boolean jsonGetBoolean (JSONObject object, String key, CharSequence label) {
    Boolean value = jsonGetVerifiedBoolean(jsonGetValue(object, key), key, label);
    if (value == null) return false;
    return value;
  }

  protected static int jsonGetInteger (JSONObject object, String key, CharSequence label) {
    Integer value = jsonGetVerifiedInteger(jsonGetValue(object, key), key, label);
    if (value == null) return 0;
    return value;
  }

  protected static long jsonGetLong (JSONObject object, String key, CharSequence label) {
    Long value = jsonGetVerifiedLong(jsonGetValue(object, key), key, label);
    if (value == null) return 0;
    return value;
  }

  protected static double jsonGetDouble (JSONObject object, String key, CharSequence label) {
    Double value = jsonGetVerifiedDouble(jsonGetValue(object, key), key, label);
    if (value == null) return 0d;
    return value;
  }

  private static Object jsonGetValue (JSONArray array, int index) {
    return array.opt(index);
  }

  protected static JSONObject jsonGetObject (JSONArray array, int index, CharSequence label) {
    return jsonGetVerifiedObject(jsonGetValue(array, index), index, label);
  }

  protected static JSONArray jsonGetArray (JSONArray array, int index, CharSequence label) {
    return jsonGetVerifiedArray(jsonGetValue(array, index), index, label);
  }

  protected static String jsonGetString (JSONArray array, int index, CharSequence label) {
    return jsonGetVerifiedString(jsonGetValue(array, index), index, label);
  }

  protected static boolean jsonGetBoolean (JSONArray array, int index, CharSequence label) {
    Boolean value = jsonGetVerifiedBoolean(jsonGetValue(array, index), index, label);
    if (value == null) return false;
    return value;
  }

  protected static int jsonGetInteger (JSONArray array, int index, CharSequence label) {
    Integer value = jsonGetVerifiedInteger(jsonGetValue(array, index), index, label);
    if (value == null) return 0;
    return value;
  }

  protected static long jsonGetLong (JSONArray array, int index, CharSequence label) {
    Long value = jsonGetVerifiedLong(jsonGetValue(array, index), index, label);
    if (value == null) return 0;
    return value;
  }

  protected static double jsonGetDouble (JSONArray array, int index, CharSequence label) {
    Double value = jsonGetVerifiedDouble(jsonGetValue(array, index), index, label);
    if (value == null) return 0d;
    return value;
  }
}
