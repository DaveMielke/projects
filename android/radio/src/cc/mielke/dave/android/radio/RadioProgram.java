package cc.mielke.dave.android.radio;

public abstract class RadioProgram extends RadioComponent {
  private final RadioPlayer[] allPlayers;
  private RadioPlayer currentPlayer = null;

  protected RadioProgram (RadioPlayer... players) {
    super();
    allPlayers = players;
  }

  public final boolean play () {
    synchronized (allPlayers) {
      currentPlayer = null;

      for (RadioPlayer player : allPlayers) {
        if (player.play(this)) {
          currentPlayer = player;
          return true;
        }
      }

      return false;
    }
  }

  public final void start () {
    play();
  }

  public final void stop () {
  }
}
