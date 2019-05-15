package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import cc.mielke.dave.android.base.JSONLoader;
import org.json.JSONObject;
import java.util.Iterator;

import android.util.Log;

public class RadioPrograms extends RadioComponent {
  private final static String LOG_TAG = RadioPrograms.class.getName();

  private final static Map<String, RadioProgram> programs = new HashMap<>();

  private final void addPrograms () {
    new JSONLoader() {
      @Override
      protected void load (JSONObject root, String name) {
        Iterator<String> titles = root.keys();

        while (titles.hasNext()) {
          String title = titles.next();
          JSONObject object = root.optJSONObject(title);

          if (object != null) {
            if (getProgram(title) == null) {
              RadioProgram program = new SimpleProgramBuilder()
                .setProgramName(title)
                .setMusicCollection(object.optString("music", null))
                .setBookCollection(object.optString("book", null))
                .setAnnounceHours(object.optBoolean("hours"))
                .setAnnounceMinutes(object.optBoolean("minutes"))
                .build();

              if (program != null) programs.put(title, program);
            } else {
              Log.w(LOG_TAG, ("program already defined: " + title));
            }
          } else {
            Log.w(LOG_TAG, ("program not a JSON object: " + title));
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
