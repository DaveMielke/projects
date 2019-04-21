package cc.mielke.dave.android.radio;

import java.util.List;
import java.util.LinkedList;

import android.util.Log;

public abstract class RadioProgram extends RadioComponent {
  private final static String LOG_TAG = RadioProgram.class.getName();

  protected RadioProgram () {
    super();
  }

  private final List<RadioPlayer> allPlayers = new LinkedList<>();
  private RadioPlayer currentPlayer = null;

  protected final void addPlayers (RadioPlayer... players) {
    synchronized (allPlayers) {
      for (RadioPlayer player : players) {
        allPlayers.add(player);
      }
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

        player.ensureDelay(player.getBaseDelay());
        next = Math.min(next, player.getEarliestTime());
      }

      {
        Log.i(LOG_TAG, "nothing to play");
        long delay = next - now;
        getHandler().postDelayed(playCallback, delay);
      }
    }
  }

  public final void start () {
    play();
  }

  public final void stop () {
    getHandler().removeCallbacks(playCallback);
  }
}
