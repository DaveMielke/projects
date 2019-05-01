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

  public final String getExternalName () {
    {
      String name = getName();
      if ((name != null) && !name.isEmpty()) return name;
    }

    return getString(R.string.name_anonymousProgram);
  }

  public static String getExternalName (RadioProgram program) {
    if (program == null) return getString(R.string.name_noProgram);
    return program.getExternalName();
  }

  protected final void logAction (String action) {
    if (RadioParameters.LOG_RADIO_PROGRAMS) {
      Log.d(LOG_TAG,
        String.format(
          "%s: %s", action, getExternalName()
        )
      );
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
        if (RadioParameters.LOG_PLAYER_SCHEDULING) {
          Log.d(LOG_TAG, ("asynchronous player start: " + getExternalName()));
        }

        play();
      }
    };

  private final void play () {
    synchronized (this) {
      if (currentPlayer != null) {
        throw new IllegalStateException("already playing");
      }

      if (isActive) {
        if (RadioParameters.LOG_PLAYER_SCHEDULING) {
          Log.d(LOG_TAG, ("selecting player: " + getExternalName()));
        }
      } else {
        if (RadioParameters.LOG_PLAYER_SCHEDULING) {
          Log.d(LOG_TAG, ("program not active: " + getExternalName()));
        }

        return;
      }

      long now = getCurrentTime();
      long next = Long.MAX_VALUE;

      for (RadioPlayer player : allPlayers) {
        if (now >= player.getEarliestTime()) {
          if (player.play()) {
            currentPlayer = player;
            return;
          }

          player.ensureDelay(player.getBaseDelay());
        }

        next = Math.min(next, player.getEarliestTime());
      }

      if (RadioParameters.LOG_PLAYER_SCHEDULING) {
        Log.d(LOG_TAG, "nothing to play");
      }

      {
        long delay = Math.max((next - now), 0);
        post(delay, retryCallback);
      }
    }
  }

  public final void onPlayerFinished (RadioPlayer player) {
    if (RadioParameters.LOG_PLAYER_SCHEDULING) {
      Log.d(LOG_TAG, ("player finished: " + player.getName()));
    }

    synchronized (this) {
      currentPlayer = null;
      post(retryCallback);
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
