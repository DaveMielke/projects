package cc.mielke.dave.android.radio.programs;
import cc.mielke.dave.android.radio.*;

public class Hourly extends RadioProgram {
  public Hourly () {
    super(
      new HourlyPlayer()
    );
  }
}
