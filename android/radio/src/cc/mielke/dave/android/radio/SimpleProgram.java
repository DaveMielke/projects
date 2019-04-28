package cc.mielke.dave.android.radio;

public class SimpleProgram extends RadioProgram {
  public SimpleProgram (String music, boolean hourly, String book) {
    super();

    if (hourly) addPlayers(new HourPlayer(this));
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
