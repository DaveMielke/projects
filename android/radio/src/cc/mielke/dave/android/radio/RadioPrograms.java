package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import java.io.File;
import java.util.Properties;

public class RadioPrograms extends RadioComponent {
  private final static Map<String, RadioProgram> programs = new HashMap<>();
  private RadioProgram currentProgram = null;

  private final void addPrograms () {
    File directory = RadioApplication.getExternalDirectory();

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
          boolean hourly = properties.getProperty("hourly", null) != null;

          RadioProgram program = new SimpleProgram(music, hourly, book);
          program.setName(name);
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

  public final RadioPrograms setProgram (RadioProgram program) {
    synchronized (this) {
      if (currentProgram != null) currentProgram.stop();
      currentProgram = program;
      if (currentProgram != null) currentProgram.start();
    }

    return this;
  }
}
