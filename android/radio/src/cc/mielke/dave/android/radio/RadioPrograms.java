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
      protected void load (JSONObject root, String path) {
        for (String name : jsonGetKeys(root)) {
          JSONObject properties = jsonGetObject(root, name, path);
          if (properties == null) continue;

          if (getProgram(name) != null) {
            Log.w(LOG_TAG, ("program already defined: " + name));
          } else {
            RadioProgram program = new SimpleProgramBuilder()
              .setProgramName(name)
              .setMusicCollection(jsonGetString(properties, "music", name))
              .setBookCollection(jsonGetString(properties, "book", name))
              .setAnnounceHours(jsonGetBoolean(properties, "hours", name))
              .setAnnounceMinutes(jsonGetBoolean(properties, "minutes", name))
              .build();

            jsonLogUnhandledKeys(properties, name);
            if (program != null) programs.put(name, program);
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
