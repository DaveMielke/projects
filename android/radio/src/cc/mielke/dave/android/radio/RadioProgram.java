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
      if (programName != null) {
        throw new IllegalStateException("name already set");
      }

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
  private boolean isActive = false;

  public final RadioPlayer getCurrentPlayer () {
    synchronized (this) {
      return currentPlayer;
    }
  }

  protected final RadioProgram addPlayers (RadioPlayer... players) {
    synchronized (this) {
      for (RadioPlayer player : players) {
        player.setProgram(this);
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
    synchronized (this) {
      if (!isActive) return;

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
    synchronized (this) {
      if (!isActive) {
        logAction("starting");
        isActive = true;
        play();
      }
    }
  }

  public final void stop () {
    synchronized (this) {
      if (isActive) {
        logAction("stopping");
        isActive = false;

        getHandler().removeCallbacks(playCallback);
        if (currentPlayer != null) currentPlayer.stop();
      }
    }
  }
}
