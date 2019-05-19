package cc.mielke.dave.android.radio;

import java.util.Set;

import java.util.Map;
import java.util.HashMap;

import java.util.List;
import java.util.LinkedList;

import cc.mielke.dave.android.base.JSONObjectLoader;
import org.json.JSONObject;
import org.json.JSONArray;

import android.util.Log;

public class RadioSchedules extends RadioComponent {
  private final static String LOG_TAG = RadioSchedules.class.getName();

  private final Map<String, RadioSchedule> radioSchedules = new HashMap<>();

  public final String[] getNames () {
    synchronized (this) {
      Set<String> names = radioSchedules.keySet();
      return names.toArray(new String[names.size()]);
    }
  }

  public final RadioSchedule getSchedule (String name) {
    synchronized (this) {
      return radioSchedules.get(name);
    }
  }

  private final void loadSchedules () {
    new JSONObjectLoader() {
      @Override
      protected void load (JSONObject root, String path) {
        List<String> rules = new LinkedList<>();

        for (String name : jsonGetKeys(root)) {
          JSONArray array = jsonGetArray(root, name, path);
          if (array == null) continue;

          if (getSchedule(name) != null) {
            Log.w(LOG_TAG, ("schedule already defined: " + name));
          } else {
            int count = array.length();

            for (int index=0; index<count; index+=1) {
              String rule = jsonGetString(array, index, name);
              if (rule != null) rules.add(rule);
            }

            if (rules.isEmpty()) {
              Log.w(LOG_TAG, ("no rules: " + name));
            } else {
              radioSchedules.put(name, new RadioSchedule(rules.toArray(new String[rules.size()])));
            }
          }
        }
      }
    }.load(RadioParameters.RADIO_SCHEDULES_FILE);
  }

  public RadioSchedules () {
    super();
    loadSchedules();
  }
}
