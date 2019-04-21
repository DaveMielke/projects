package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Christian extends RadioProgram {
  public Christian () {
    super();

    addPlayers(
      new HourlyPlayer(this),
      new BookPlayer(this).setCollection("Bible"),
      new MusicPlayer(this).setCollection("Christian")
    );
  }
}
