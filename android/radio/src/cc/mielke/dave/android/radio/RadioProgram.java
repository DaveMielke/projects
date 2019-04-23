package cc.mielke.dave.android.radio;

import java.util.List;
import java.util.LinkedList;

import android.util.Log;

public class RadioProgram extends RadioComponent {
  private final static String LOG_TAG = RadioProgram.class.getName();

  public RadioProgram () {
    super();
  }

  private String programName = null;

  public final String getName () {
    synchronized (this) {
      return programName;
    }
  }

  public final RadioProgram setName (String name) {
    synchronized (this) {
      programName = name;
      return this;
    }
  }

  protected final void logAction (String action) {
    StringBuilder log = new StringBuilder(action);

    {
      String name = getName();

      if (name != null) {
        if (!name.isEmpty()) {
          log.append(": ");
          log.append(name);
        }
      }
    }

    Log.d(LOG_TAG, log.toString());
  }

  private final List<RadioPlayer> allPlayers = new LinkedList<>();
  private RadioPlayer currentPlayer = null;
  private boolean isStarted = false;

  protected final RadioProgram addPlayers (RadioPlayer... players) {
    synchronized (allPlayers) {
      for (RadioPlayer player : players) {
        allPlayers.add(player);
      }
    }

    return this;
  }

  private final Runnable playCallback =
    new Runnable() {
      @Override
      public void run () {
        play();
      }
    };

  public final void play () {
    synchronized (allPlayers) {
      if (!isStarted) return;

      long now = getCurrentTime();
      long next = Long.MAX_VALUE;

      currentPlayer = null;

      for (RadioPlayer player : allPlayers) {
        if (now >= player.getEarliestTime()) {
          if (player.play()) {
            player.onPlayStart();
            currentPlayer = player;
            return;
          }

          player.ensureDelay(player.getBaseDelay());
        }

        next = Math.min(next, player.getEarliestTime());
      }

      {
        Log.i(LOG_TAG, "nothing to play");
        long delay = Math.max((next - now), 0);
        post(delay, playCallback);
      }
    }
  }

  public final void start () {
    synchronized (allPlayers) {
      if (!isStarted) {
        logAction("starting");
        isStarted = true;

        play();
      }
    }
  }

  public final void stop () {
    synchronized (allPlayers) {
      if (isStarted) {
        logAction("stopping");
        isStarted = false;

        getHandler().removeCallbacks(playCallback);
        if (currentPlayer != null) currentPlayer.stop();
      }
    }
  }
}
