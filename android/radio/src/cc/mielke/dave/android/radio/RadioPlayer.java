package cc.mielke.dave.android.radio;

import java.util.concurrent.TimeUnit;

import android.util.Log;

public abstract class RadioPlayer extends RadioComponent {
  private final static String LOG_TAG = RadioPlayer.class.getName();

  protected RadioPlayer () {
    super();
  }

  private RadioProgram radioProgram = null;
  private long baseDelay = 0;
  private double relativeDelay = 0d;
  private long maximumDelay = Long.MAX_VALUE;

  public final RadioProgram getProgram () {
    synchronized (this) {
      return radioProgram;
    }
  }

  public final RadioPlayer setProgram (RadioProgram program) {
    synchronized (this) {
      if (radioProgram != null) {
        String message = "program already set";

        String name = radioProgram.getName();
        if (name != null) message += ": " + name;

        throw new IllegalStateException(message);
      }

      radioProgram = program;
      return this;
    }
  }

  public final long getBaseDelay () {
    synchronized (this) {
      return baseDelay;
    }
  }

  public final RadioPlayer setBaseDelay (long milliseconds) {
    synchronized (this) {
      baseDelay = milliseconds;
      return this;
    }
  }

  public final RadioPlayer setBaseDelay (long count, TimeUnit unit) {
    return setBaseDelay(unit.toMillis(count));
  }

  public final double getRelativeDelay () {
    synchronized (this) {
      return relativeDelay;
    }
  }

  public final RadioPlayer setRelativeDelay (double multiplier) {
    synchronized (this) {
      relativeDelay = multiplier;
      return this;
    }
  }

  public final long getMaximumDelay () {
    synchronized (this) {
      return maximumDelay;
    }
  }

  public final RadioPlayer setMaximumDelay (long milliseconds) {
    synchronized (this) {
      maximumDelay = milliseconds;
      return this;
    }
  }

  public final RadioPlayer setMaximumDelay (long count, TimeUnit unit) {
    return setMaximumDelay(unit.toMillis(count));
  }

  public String getName () {
    return getClass().getSimpleName();
  }

  protected final void logPlaying (String type, CharSequence data) {
    Log.i(LOG_TAG, String.format("playing %s: %s", type, data));
  }

  private long earliestTime = 0;
  private Long startTime = null;

  public final long getEarliestTime () {
    synchronized (this) {
      return earliestTime;
    }
  }

  public final RadioPlayer setEarliestTime (long time) {
    synchronized (this) {
      earliestTime = Math.max(earliestTime, time);
      return this;
    }
  }

  public final RadioPlayer ensureDelay (long milliseconds) {
    return setEarliestTime(getCurrentTime() + milliseconds);
  }

  public final RadioPlayer ensureDelay (long count, TimeUnit unit) {
    return ensureDelay(unit.toMillis(count));
  }

  protected final void onPlayStart () {
    synchronized (this) {
      if (RadioParameters.LOG_PLAYER_SCHEDULING) {
        Log.d(LOG_TAG, ("playing started: " + getName()));
      }

      startTime = getCurrentTime();
    }
  }

  public final void onPlayEnd () {
    synchronized (this) {
      long now = getCurrentTime();
      long duration = now - startTime;
      startTime = null;

      long delay = getBaseDelay();
      delay += Math.round((double)duration * getRelativeDelay());
      delay = Math.min(delay, getMaximumDelay());
      setEarliestTime(now + delay);

      if (RadioParameters.LOG_PLAYER_SCHEDULING) {
        Log.d(LOG_TAG, ("playing ended: " + getName()));
      }

      getProgram().onPlayerFinished(this);
    }
  }

  protected static void onRadioPlayerFinished (RadioPlayer player) {
    if (player == null) {
      player = getRadioPlayer();
    }

    if (player != null) {
      player.onPlayEnd();
    } else {
      Log.w(LOG_TAG, "no active player");
    }
  }

  public void stop () {
  }

  public abstract boolean play ();
}
