package cc.mielke.dave.android.radio;

public abstract class RadioProgram extends RadioComponent {
  private final RadioPlayer[] allPlayers;
  private RadioPlayer currentPlayer = null;

  protected RadioProgram (RadioPlayer... players) {
    super();
    allPlayers = players;

    for (RadioPlayer player : allPlayers) {
      player.setProgram(this);
    }
  }

  public final boolean play () {
    long now = getCurrentTime();

    synchronized (allPlayers) {
      currentPlayer = null;

      for (RadioPlayer player : allPlayers) {
        if (now < player.getEarliestTime()) continue;

        if (player.play()) {
          player.onPlayStart();
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
