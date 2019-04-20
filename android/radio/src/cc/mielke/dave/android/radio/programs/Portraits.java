package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Portraits extends RadioProgram {
  public Portraits () {
    super(
      new HourlyPlayer(),
      new MusicPlayer().setCollection("Portraits")
    );
  }
}
