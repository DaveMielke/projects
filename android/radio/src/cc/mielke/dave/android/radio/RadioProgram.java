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

  private final Runnable playCallback =
    new Runnable() {
      @Override
      public void run () {
        play();
      }
    };

  public final void play () {
    long now = getCurrentTime();
    long next = Long.MAX_VALUE;

    synchronized (allPlayers) {
      currentPlayer = null;

      for (RadioPlayer player : allPlayers) {
        long earliest = player.getEarliestTime();
        if (earliest < next) next = earliest;
        if (now < earliest) continue;

        if (player.play()) {
          player.onPlayStart();
          currentPlayer = player;
          return;
        }
      }

      long delay = next - now;
      getHandler().postDelayed(playCallback, delay);
    }
  }

  public final void start () {
    play();
  }

  public final void stop () {
  }
}
