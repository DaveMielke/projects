package cc.mielke.dave.android.radio;

public abstract class RadioProgram extends RadioComponent {
  private final RadioPlayer[] allPlayers;
  private RadioPlayer currentPlayer = null;

  protected RadioProgram (RadioPlayer... players) {
    super();
    allPlayers = players;
  }

  private final boolean next () {
    synchronized (allPlayers) {
      currentPlayer = null;

      for (RadioPlayer player : allPlayers) {
        if (player.play()) {
          currentPlayer = player;
          return true;
        }
      }

      return false;
    }
  }

  public final void start () {
    next();
  }

  public final void stop () {
  }
}
