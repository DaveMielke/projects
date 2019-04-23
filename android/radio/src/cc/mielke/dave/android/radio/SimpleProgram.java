package cc.mielke.dave.android.radio;

import java.util.regex.Pattern;

public class SimpleProgram extends RadioProgram {
  private final static Pattern splitPattern = Pattern.compile(
    "(?<=\\p{lower})()(?=\\p{upper})"
  );

  public SimpleProgram (String music, boolean hourly, String book) {
    super();
    setName(splitPattern.matcher(getClass().getSimpleName()).replaceAll(" "));

    if (hourly) addPlayers(new HourlyAnnouncementPlayer(this));
    if (book != null) addPlayers(new BookPlayer(this).setCollection(book));
    if (music != null) addPlayers(new MusicPlayer(this).setCollection(music));
  }

  protected SimpleProgram (String music, boolean hourly) {
    this(music, hourly, null);
  }

  protected SimpleProgram (String music) {
    this(music, false);
  }

  protected SimpleProgram (String music, String book) {
    this(music, false, book);
  }
}
