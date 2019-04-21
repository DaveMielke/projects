package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Portraits extends RadioProgram {
  public Portraits () {
    super();

    addPlayers(
      new HourlyPlayer(this),
      new MusicPlayer(this).setCollection("Portraits")
    );
  }
}
