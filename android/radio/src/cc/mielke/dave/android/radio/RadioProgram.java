package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class RadioProgram extends RadioComponent {
  private final static String LOG_TAG = RadioProgram.class.getName();

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
        if (now < player.getEarliestTime()) continue;

        if (player.play()) {
          player.onPlayStart();
          currentPlayer = player;
          return;
        }

        next = Math.min(next, player.getEarliestTime());
      }

      Log.i(LOG_TAG, "nothing to play");
      long delay = next - now;
      getHandler().postDelayed(playCallback, delay);
    }
  }

  public final void start () {
    play();
  }

  public final void stop () {
    getHandler().removeCallbacks(playCallback);
  }
}
