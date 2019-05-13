package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import cc.mielke.dave.android.base.PropertiesLoader;
import java.util.Properties;

import android.util.Log;

public class RadioPrograms extends RadioComponent {
  private final static String LOG_TAG = RadioPrograms.class.getName();

  private final static Map<String, RadioProgram> programs = new HashMap<>();
  private RadioProgram currentProgram = null;

  private final void addPrograms () {
    new PropertiesLoader() {
      @Override
      protected void load (Properties properties, String defaultName) {
        String name = properties.getProperty("name", null);
        if (name == null) name = defaultName;

        if (getProgram(name) == null) {
          RadioProgram program = new SimpleProgramBuilder()
            .setProgramName(name)
            .setMusicCollection(properties.getProperty("music", null))
            .setBookCollection(properties.getProperty("book", null))
            .setAnnounceHours(properties.getProperty("hours", null) != null)
            .setAnnounceMinutes(properties.getProperty("minutes", null) != null)
            .build();

          if (program != null) programs.put(name, program);
        } else {
          Log.w(LOG_TAG, ("program already defined: " + name));
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
