package cc.mielke.dave.android.radio;

import java.util.concurrent.TimeUnit;

import android.util.Log;

public abstract class RadioPlayer extends RadioComponent {
  private final static String LOG_TAG = RadioPlayer.class.getName();

  protected RadioPlayer () {
    super();
  }

  private RadioProgram radioProgram = null;
  private long minimumDelay = 0;
  private long maximumDelay = Long.MAX_VALUE;
  private double relativeDelay = 0d;

  public final RadioProgram getProgram () {
    synchronized (this) {
      return radioProgram;
    }
  }

  public final RadioPlayer setProgram (RadioProgram program) {
    synchronized (this) {
      radioProgram = program;
      return this;
    }
  }

  public final long getMinimumDelay () {
    synchronized (this) {
      return minimumDelay;
    }
  }

  public final RadioPlayer setMinimumDelay (long milliseconds) {
    synchronized (this) {
      minimumDelay = milliseconds;
      return this;
    }
  }

  public final RadioPlayer setMinimumDelay (long count, TimeUnit unit) {
    return setMinimumDelay(unit.toMillis(count));
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

  protected final void logPlaying (String type, String data) {
    Log.i(LOG_TAG, String.format("playing %s: %s", type, data));
  }

  private long earliestTime = 0;
  private Long startTime = null;

  public final long getEarliestTime () {
    synchronized (this) {
      return earliestTime;
    }
  }

  public final void setEarliestTime (long time) {
    synchronized (this) {
      earliestTime = Math.max(earliestTime, time);
    }
  }

  public final void ensureDelay (long milliseconds) {
    setEarliestTime(getCurrentTime() + milliseconds);
  }

  public final void ensureDelay (long count, TimeUnit unit) {
    ensureDelay(unit.toMillis(count));
  }

  public final void onPlayStart () {
    synchronized (this) {
      startTime = getCurrentTime();
    }
  }

  public final void onPlayEnd () {
    synchronized (this) {
      long now = getCurrentTime();
      long duration = now - startTime;
      startTime = null;

      long delay = Math.round((double)duration * getRelativeDelay());
      delay = Math.max(delay, getMinimumDelay());
      delay = Math.min(delay, getMaximumDelay());

      setEarliestTime(now + delay);
    }

    getProgram().play();
  }

  public abstract boolean play ();
}
