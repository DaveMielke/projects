package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import cc.mielke.dave.android.base.JSONObjectLoader;
import org.json.JSONObject;

import android.util.Log;

public class CustomPrograms extends RadioComponent {
  private final static String LOG_TAG = CustomPrograms.class.getName();

  private final Map<String, RadioProgram> customPrograms = new HashMap<>();

  public final String[] getNames () {
    synchronized (this) {
      Set<String> names = customPrograms.keySet();
      return names.toArray(new String[names.size()]);
    }
  }

  public final RadioProgram getProgram (String name) {
    synchronized (this) {
      return customPrograms.get(name);
    }
  }

  private final void loadPrograms () {
    new JSONObjectLoader() {
      @Override
      protected void load (JSONObject root, String path) {
        for (String name : jsonGetKeys(root)) {
          JSONObject properties = jsonGetObject(root, name, path);
          if (properties == null) continue;

          if (getProgram(name) != null) {
            Log.w(LOG_TAG, ("program already defined: " + name));
          } else {
            RadioProgram program = new CustomProgramBuilder()
              .setProgramName(name)
              .setMusicCollection(jsonGetString(properties, "music", name))
              .setBookCollection(jsonGetString(properties, "book", name))
              .setAnnounceHours(jsonGetBoolean(properties, "hours", name))
              .setAnnounceMinutes(jsonGetBoolean(properties, "minutes", name))
              .build();

            jsonLogUnhandledKeys(properties, name);
            if (program != null) customPrograms.put(name, program);
          }
        }
      }
    }.load(RadioParameters.CUSTOM_PROGRAMS_FILE);
  }

  public CustomPrograms () {
    super();
    loadPrograms();
  }
}
