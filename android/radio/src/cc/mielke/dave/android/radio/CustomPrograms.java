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
  private final Map<String, RadioProgram> identifiedPrograms = new HashMap<>();

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

  public final RadioProgram getProgramByIdentifier (String identifier) {
    synchronized (this) {
      return identifiedPrograms.get(identifier);
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
            String identifier = jsonGetString(properties, "identifier", name);

            RadioProgram program = new CustomProgramBuilder()
              .setProgramName(name)
              .setMusicCollection(jsonGetString(properties, "music", name))
              .setBookCollection(jsonGetString(properties, "book", name))
              .setAnnounceHours(jsonGetBoolean(properties, "hours", name))
              .setAnnounceMinutes(jsonGetBoolean(properties, "minutes", name))
              .build();

            jsonLogUnhandledKeys(properties, name);
            if (program == null) continue;
            customPrograms.put(name, program);

            if ((identifier != null) && !identifier.isEmpty()) {
              RadioProgram oldProgram = identifiedPrograms.get(identifier);

              if (oldProgram == null) {
                identifiedPrograms.put(identifier, program);
              } else {
                Log.w(LOG_TAG,
                  String.format(
                    "program identifier already defined: %s: %s & %s",
                    identifier, name, oldProgram.getName()
                  )
                );
              }
            }
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
