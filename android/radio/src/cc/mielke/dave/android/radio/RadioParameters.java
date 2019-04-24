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

  public final static long BOOK_INITIAL_DELAY = TimeUnit.MINUTES.toMillis(9);
  public final static long BOOK_BASE_DELAY = TimeUnit.MINUTES.toMillis(8);
  public final static double BOOK_RELATIVE_DELAY = 1.4d;
  public final static long BOOK_MAXIMUM_DELAY = TimeUnit.MINUTES.toMillis(25);

  public final static long TTS_RETRY_DELAY = TimeUnit.SECONDS.toMillis(30);
}
