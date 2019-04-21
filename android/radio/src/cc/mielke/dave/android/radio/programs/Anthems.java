package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Anthems extends RadioProgram {
  public Anthems () {
    super(
      new HourlyPlayer(),
      new MusicPlayer().setCollection("Anthems")
    );
  }
}
