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

          String musicCollection = properties.getProperty("music", null);
          RadioPlayer musicPlayer = null;

          String bookCollection = properties.getProperty("book", null);
          RadioPlayer bookPlayer = null;

          boolean announceHours = properties.getProperty("hours", null) != null;
          RadioPlayer hourPlayer = null;

          boolean announceMinutes = properties.getProperty("minutes", null) != null;
          RadioPlayer minutePlayer = null;

          if (musicCollection != null) {
            musicPlayer = new MusicPlayer().setCollection(musicCollection);
          }

          if (bookCollection != null) {
            bookPlayer = new BookPlayer().setCollection(bookCollection);

            if (musicPlayer != null) {
              bookPlayer.setBaseDelay(RadioParameters.BOOK_BASE_DELAY);
              bookPlayer.setRelativeDelay(RadioParameters.BOOK_RELATIVE_DELAY);
              bookPlayer.setMaximumDelay(RadioParameters.BOOK_MAXIMUM_DELAY);
              bookPlayer.ensureDelay(RadioParameters.BOOK_INITIAL_DELAY);
            }
          }

          if (announceHours) {
            hourPlayer = new HourPlayer();

            if ((bookPlayer != null) && (musicPlayer != null)) {
              final RadioPlayer book = bookPlayer;

              hourPlayer.addOnFinishedListener(
                new RadioPlayer.OnFinishedListener() {
                  @Override
                  public void onFinished (RadioPlayer player) {
                    book.ensureDelay(RadioParameters.BOOK_HOUR_DELAY);
                  }
                }
              );
            }
          }

          if (announceMinutes) {
            minutePlayer = new MinutePlayer();
          }

          RadioProgram program = new RadioProgram();
          program.setName(name);

          boolean hasPlayers = program.addPlayers(
            hourPlayer,
            minutePlayer,
            bookPlayer,
            musicPlayer
          );

          if (hasPlayers) {
            programs.put(name, program);
          } else {
            Log.w(LOG_TAG, ("no players: " + name));
          }
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
