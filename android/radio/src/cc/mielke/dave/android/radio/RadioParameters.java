package cc.mielke.dave.android.radio;

import java.util.concurrent.TimeUnit;

public abstract class RadioParameters {
  private RadioParameters () {
  }

  public final static String MUSIC_LIBRARY_FILE = "music";
  public final static String BOOK_LIBRARY_FILE = "books";
  public final static String RADIO_PROGRAMS_SUBDIRECTORY = "Programs";

  public final static String[] AUDIO_EXTENSIONS = new String[] {
    ".mp3", ".mid"
  };

  public final static long PROGRAM_DEFAULT_DELAY = TimeUnit.MINUTES.toMillis(20);

  public final static long BOOK_INITIAL_DELAY = TimeUnit.MINUTES.toMillis(9);
  public final static long BOOK_BASE_DELAY = TimeUnit.MINUTES.toMillis(8);
  public final static double BOOK_RELATIVE_DELAY = 1.4d;
  public final static long BOOK_MAXIMUM_DELAY = TimeUnit.MINUTES.toMillis(25);
  public final static long BOOK_HOUR_DELAY = TimeUnit.MINUTES.toMillis(3);

  public final static long POSITION_MONITOR_INTERVAL = TimeUnit.SECONDS.toMillis(1);
  public final static long FILE_PREVIOUS_THRESHOLD = TimeUnit.SECONDS.toMillis(5);

  public final static long TTS_RETRY_DELAY = TimeUnit.SECONDS.toMillis(30);

  public final static boolean LOG_AUDIO_FOCUS = false;
  public final static boolean LOG_COLLECTION_PLAYER = false;
  public final static boolean LOG_PLAYER_SCHEDULING = false;
  public final static boolean LOG_POSITION_MONITOR = false;
  public final static boolean LOG_RADIO_PROGRAMS = false;
  public final static boolean LOG_SPEECH_PLAYER = false;
  public final static boolean LOG_URI_PLAYER = false;
}
