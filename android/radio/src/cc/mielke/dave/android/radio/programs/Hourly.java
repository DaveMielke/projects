package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Hourly extends RadioProgram {
  public Hourly () {
    super();

    addPlayers(
      new HourlyPlayer(this)
    );
  }
}
