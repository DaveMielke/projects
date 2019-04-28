package cc.mielke.dave.android.radio;

public class SimpleProgram extends RadioProgram {
  public SimpleProgram (String music, boolean hours, String book) {
    super();

    if (hours) addPlayers(new HourPlayer());
    if (book != null) addPlayers(new BookPlayer().setCollection(book));
    if (music != null) addPlayers(new MusicPlayer().setCollection(music));
  }

  protected SimpleProgram (String music, boolean hours) {
    this(music, hours, null);
  }

  protected SimpleProgram (String music) {
    this(music, false);
  }

  protected SimpleProgram (String music, String book) {
    this(music, false, book);
  }
}
