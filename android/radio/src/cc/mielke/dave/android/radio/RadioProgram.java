package cc.mielke.dave.android.radio;

public abstract class RadioProgram extends RadioComponent {
  private final RadioPlayer[] radioPlayers;

  protected RadioProgram (RadioPlayer... players) {
    super();
    radioPlayers = players;
  }

  public final void start () {
  }

  public final void stop () {
  }
}
