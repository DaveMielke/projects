package cc.mielke.dave.android.radio;

import android.util.Log;

public class SimpleProgramBuilder extends RadioComponent {
  private final static String LOG_TAG = SimpleProgramBuilder.class.getName();

  public SimpleProgramBuilder () {
    super();
  }

  private String programName = null;
  private String musicCollection = null;
  private String bookCollection = null;
  private boolean announceHours = false;
  private boolean announceMinutes = false;

  public final SimpleProgramBuilder setProgramName (String name) {
    programName = name;
    return this;
  }

  public final SimpleProgramBuilder setMusicCollection (String collection) {
    musicCollection = collection;
    return this;
  }

  public final SimpleProgramBuilder setBookCollection (String collection) {
    bookCollection = collection;
    return this;
  }

  public final SimpleProgramBuilder setAnnounceHours (boolean yes) {
    announceHours = yes;
    return this;
  }

  public final SimpleProgramBuilder setAnnounceMinutes (boolean yes) {
    announceMinutes = yes;
    return this;
  }

  public final RadioProgram build () {
    RadioPlayer musicPlayer = null;
    RadioPlayer bookPlayer = null;
    RadioPlayer hourPlayer = null;
    RadioPlayer minutePlayer = null;

    if (musicCollection != null) {
      musicPlayer = new MusicPlayer().setCollection(musicCollection);
    }

    if (bookCollection != null) {
      bookPlayer = new BookPlayer().setCollection(bookCollection);

      if (musicPlayer != null) {
        bookPlayer.setInitialDelay(RadioParameters.BOOK_INITIAL_DELAY);
        bookPlayer.setBaseDelay(RadioParameters.BOOK_BASE_DELAY);
        bookPlayer.setRelativeDelay(RadioParameters.BOOK_RELATIVE_DELAY);
        bookPlayer.setMaximumDelay(RadioParameters.BOOK_MAXIMUM_DELAY);
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

    String name = programName;
    if (name == null) name = getString(R.string.name_anonymousProgram);

    RadioProgram program = new RadioProgram();
    program.setName(name);

    boolean hasPlayers = program.addPlayers(
      hourPlayer,
      minutePlayer,
      bookPlayer,
      musicPlayer
    );

    if (hasPlayers) return program;
    Log.w(LOG_TAG, ("no players: " + programName));
    return null;
  }
}
