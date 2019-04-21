package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Bands extends RadioProgram {
  public Bands () {
    super();

    addPlayers(
      new HourlyPlayer(this),
      new MusicPlayer(this).setCollection("Bands")
    );
  }
}
