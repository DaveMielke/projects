package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Bands extends RadioProgram {
  public Bands () {
    super(
      new HourlyPlayer(),
      new MusicPlayer().setCollection("Bands")
    );
  }
}
