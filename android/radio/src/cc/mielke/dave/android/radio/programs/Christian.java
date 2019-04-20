package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Christian extends RadioProgram {
  public Christian () {
    super(
      new HourlyPlayer(),
      new BookPlayer().setCollection("Bible"),
      new MusicPlayer().setCollection("Christian")
    );
  }
}
