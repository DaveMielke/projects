package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import java.io.File;
import java.util.Properties;

import android.util.Log;

public class RadioPrograms extends RadioComponent {
  private final static String LOG_TAG = RadioPrograms.class.getName();

  private final static Map<String, RadioProgram> programs = new HashMap<>();
  private RadioProgram currentProgram = null;

  private final void addPrograms () {
    File directory = getExternalStorageDirectory();

    if (directory != null) {
      directory = new File(directory, RadioParameters.RADIO_PROGRAMS_SUBDIRECTORY);
      File[] files = directory.listFiles();

      if (files != null) {
        for (File file : files) {
          if (!file.isFile()) continue;

          Properties properties = loadProperties(file);
          if (properties == null) continue;

          String name = properties.getProperty("name", null);
          if (name == null) name = file.getName();

          String music = properties.getProperty("music", null);
          String book = properties.getProperty("book", null);

          boolean hours = properties.getProperty("hours", null) != null;
          boolean minutes = properties.getProperty("minutes", null) != null;

          RadioProgram program = new RadioProgram();
          program.setName(name);

          if (hours) {
            program.addPlayers(new HourPlayer());
          }

          if (minutes) {
            program.addPlayers(new MinutePlayer());
          }

          if (book != null) {
            program.addPlayers(new BookPlayer().setCollection(book));
          }

          if (music != null) {
            program.addPlayers(new MusicPlayer().setCollection(music));
          }

          programs.put(name, program);
        }
      }
    }
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
        if (currentProgram != null) currentProgram.start();
      }
    }

    return this;
  }
}
