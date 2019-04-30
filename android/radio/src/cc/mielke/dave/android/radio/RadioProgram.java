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

  public final RadioProgram setName (String name) {
    synchronized (this) {
      if (programName != null) {
        throw new IllegalStateException("name already set");
      }

      programName = name;
      return this;
    }
  }

  public final String getName () {
    synchronized (this) {
      return programName;
    }
  }

  public static String getName (RadioProgram program) {
    if (program == null) return getString(R.string.name_noProgram);

    String name = program.getName();
    if ((name == null) || name.isEmpty()) return getString(R.string.name_anonymousProgram);
    return name;
  }

  protected final void logAction (String action) {
    if (RadioParameters.LOG_RADIO_PROGRAMS) {
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

  private final Runnable retryCallback =
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

      if (RadioParameters.LOG_RADIO_PROGRAMS) {
        Log.d(LOG_TAG, "nothing to play");
      }

      {
        long delay = Math.max((next - now), 0);
        post(delay, retryCallback);
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

        getHandler().removeCallbacks(retryCallback);
        if (currentPlayer != null) currentPlayer.stop();
      }
    }
  }
}
