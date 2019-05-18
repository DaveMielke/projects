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

  protected static void jsonLogProblem (CharSequence problem) {
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

  protected static String jsonKeyToString (Object key) {
    if (key instanceof String) return "\"" + key + "\"";
    if (key instanceof Integer) return "[" + key + "]";
    return null;
  }

  protected static void jsonLogUnhandledKeys (JSONObject object, CharSequence path) {
    Iterator<String> iterator = object.keys();

    while (iterator.hasNext()) {
      jsonLogProblem(
        "%s not handled: %s",
        jsonKeyToString(iterator.next()), path
      );
    }
  }

  protected static void jsonLogUnexpectedType (Object value, Object key, CharSequence path, Class... types) {
    StringBuilder problem = new StringBuilder();

    if (types != null) {
      int count = types.length;

      if (count > 0) {
        int last = count - 1;
        int index = 0;

        while (true) {
          problem.append(types[index].getSimpleName());
          if (index == last) break;

          if (count > 2) problem.append(',');
          if (++index == last) problem.append(" or");
          problem.append(' ');
        }

        problem.append(" expected");
      }
    }

    if (value != null) {
      if (problem.length() > 0) problem.append(" but ");

      if (value == JSONObject.NULL) {
        problem.append("null");
      } else {
        problem.append(value.getClass().getSimpleName());
      }

      problem.append(" found");
    }

    if (key != null) {
      if (problem.length() > 0) problem.append(" for ");
      problem.append(jsonKeyToString(key));
    }

    if ((path != null) && (path.length() > 0)) {
      if (problem.length() > 0) problem.append(": ");
      problem.append(path);
    }

    jsonLogProblem(problem);
  }

  private static <T> T jsonGetVerified (Object value, Class<? extends T> type, Object key, CharSequence path) {
    if (value != null) {
      if (type.isInstance(value)) return (T)value;
      jsonLogUnexpectedType(value, key, path, type);
    }

    return null;
  }

  private static JSONObject jsonGetVerifiedObject (Object value, Object key, CharSequence path) {
    return jsonGetVerified(value, JSONObject.class, key, path);
  }

  private static JSONArray jsonGetVerifiedArray (Object value, Object key, CharSequence path) {
    return jsonGetVerified(value, JSONArray.class, key, path);
  }

  private static String jsonGetVerifiedString (Object value, Object key, CharSequence path) {
    return jsonGetVerified(value, String.class, key, path);
  }

  private static Boolean jsonGetVerifiedBoolean (Object value, Object key, CharSequence path) {
    return jsonGetVerified(value, Boolean.class, key, path);
  }

  private static Integer jsonGetVerifiedInteger (Object value, Object key, CharSequence path) {
    return jsonGetVerified(value, Integer.class, key, path);
  }

  private static Long jsonGetVerifiedLong (Object value, Object key, CharSequence path) {
    return jsonGetVerified(value, Long.class, key, path);
  }

  private static Double jsonGetVerifiedDouble (Object value, Object key, CharSequence path) {
    return jsonGetVerified(value, Double.class, key, path);
  }

  private static Object jsonGetValue (JSONObject object, String key) {
    return object.remove(key);
  }

  protected static JSONObject jsonGetObject (JSONObject object, String key, CharSequence path) {
    return jsonGetVerifiedObject(jsonGetValue(object, key), key, path);
  }

  protected static JSONArray jsonGetArray (JSONObject object, String key, CharSequence path) {
    return jsonGetVerifiedArray(jsonGetValue(object, key), key, path);
  }

  protected static String jsonGetString (JSONObject object, String key, CharSequence path) {
    return jsonGetVerifiedString(jsonGetValue(object, key), key, path);
  }

  protected static boolean jsonGetBoolean (JSONObject object, String key, CharSequence path) {
    Boolean value = jsonGetVerifiedBoolean(jsonGetValue(object, key), key, path);
    if (value == null) return false;
    return value;
  }

  protected static int jsonGetInteger (JSONObject object, String key, CharSequence path) {
    Integer value = jsonGetVerifiedInteger(jsonGetValue(object, key), key, path);
    if (value == null) return 0;
    return value;
  }

  protected static long jsonGetLong (JSONObject object, String key, CharSequence path) {
    Long value = jsonGetVerifiedLong(jsonGetValue(object, key), key, path);
    if (value == null) return 0;
    return value;
  }

  protected static double jsonGetDouble (JSONObject object, String key, CharSequence path) {
    Double value = jsonGetVerifiedDouble(jsonGetValue(object, key), key, path);
    if (value == null) return 0d;
    return value;
  }

  private static Object jsonGetValue (JSONArray array, int index) {
    return array.opt(index);
  }

  protected static JSONObject jsonGetObject (JSONArray array, int index, CharSequence path) {
    return jsonGetVerifiedObject(jsonGetValue(array, index), index, path);
  }

  protected static JSONArray jsonGetArray (JSONArray array, int index, CharSequence path) {
    return jsonGetVerifiedArray(jsonGetValue(array, index), index, path);
  }

  protected static String jsonGetString (JSONArray array, int index, CharSequence path) {
    return jsonGetVerifiedString(jsonGetValue(array, index), index, path);
  }

  protected static boolean jsonGetBoolean (JSONArray array, int index, CharSequence path) {
    Boolean value = jsonGetVerifiedBoolean(jsonGetValue(array, index), index, path);
    if (value == null) return false;
    return value;
  }

  protected static int jsonGetInteger (JSONArray array, int index, CharSequence path) {
    Integer value = jsonGetVerifiedInteger(jsonGetValue(array, index), index, path);
    if (value == null) return 0;
    return value;
  }

  protected static long jsonGetLong (JSONArray array, int index, CharSequence path) {
    Long value = jsonGetVerifiedLong(jsonGetValue(array, index), index, path);
    if (value == null) return 0;
    return value;
  }

  protected static double jsonGetDouble (JSONArray array, int index, CharSequence path) {
    Double value = jsonGetVerifiedDouble(jsonGetValue(array, index), index, path);
    if (value == null) return 0d;
    return value;
  }
}
