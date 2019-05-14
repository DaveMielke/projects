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
  private RadioProgram currentProgram = null;

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
    }.load(RadioParameters.RADIO_PROGRAMS_SUBDIRECTORY);
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

  public final RadioProgram getProgram () {
    synchronized (this) {
      return currentProgram;
    }
  }

  private final String getProgramName () {
    return RadioProgram.getExternalName(currentProgram);
  }

  public final RadioPrograms setProgram (RadioProgram newProgram) {
    synchronized (this) {
      if (newProgram != currentProgram) {
        StringBuilder log = new StringBuilder("changing program: ");

        log.append(getProgramName());
        if (currentProgram != null) currentProgram.stop();

        currentProgram = newProgram;
        log.append(" -> ");
        log.append(getProgramName());
        Log.i(LOG_TAG, log.toString());

        if (currentProgram != null) {
          currentProgram.start();
        } else {
          updateNotification();
        }
      }
    }

    return this;
  }
}
