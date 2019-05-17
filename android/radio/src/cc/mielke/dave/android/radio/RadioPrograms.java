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
        for (String title : getKeys(root)) {
          JSONObject object = getObject(root, title, name);
          if (object == null) continue;

          if (getProgram(title) != null) {
            Log.w(LOG_TAG, ("program already defined: " + title));
          } else {
            RadioProgram program = new SimpleProgramBuilder()
              .setProgramName(title)
              .setMusicCollection(getString(object, "music", title))
              .setBookCollection(getString(object, "book", title))
              .setAnnounceHours(getBoolean(object, "hours", title))
              .setAnnounceMinutes(getBoolean(object, "minutes", title))
              .build();

            if (program != null) programs.put(title, program);
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
