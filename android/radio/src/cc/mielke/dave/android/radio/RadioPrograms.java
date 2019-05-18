package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import cc.mielke.dave.android.base.JSONObjectLoader;
import org.json.JSONObject;

import android.util.Log;

public class RadioPrograms extends RadioComponent {
  private final static String LOG_TAG = RadioPrograms.class.getName();

  private final Map<String, RadioProgram> programs = new HashMap<>();

  private final void addPrograms () {
    new JSONObjectLoader() {
      @Override
      protected void load (JSONObject root, String name) {
        for (String key : jsonGetKeys(root)) {
          JSONObject properties = jsonGetObject(root, key, name);
          if (properties == null) continue;

          if (getProgram(key) != null) {
            Log.w(LOG_TAG, ("program already defined: " + key));
          } else {
            RadioProgram program = new SimpleProgramBuilder()
              .setProgramName(key)
              .setMusicCollection(jsonGetString(properties, "music", key))
              .setBookCollection(jsonGetString(properties, "book", key))
              .setAnnounceHours(jsonGetBoolean(properties, "hours", key))
              .setAnnounceMinutes(jsonGetBoolean(properties, "minutes", key))
              .build();

            jsonLogUnhandledKeys(properties, key);
            if (program != null) programs.put(key, program);
          }
        }
      }
    }.load(RadioParameters.RADIO_PROGRAMS_FILE);
  }

  public RadioPrograms () {
    super();
    addPrograms();
  }

  public final String[] getNames () {
    synchronized (this) {
      Set<String> names = programs.keySet();
      return names.toArray(new String[names.size()]);
    }
  }

  public final RadioProgram getProgram (String name) {
    synchronized (this) {
      return programs.get(name);
    }
  }
}
