package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.LinkedHashSet;

import java.util.concurrent.TimeUnit;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

public abstract class RadioPlayer extends AudioComponent {
  private final static String LOG_TAG = RadioPlayer.class.getName();

  protected RadioPlayer () {
    super();
  }

  private RadioProgram radioProgram = null;

  public String getName () {
    return getClass().getSimpleName();
  }

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

  protected boolean actionPlayPause () {
    return false;
  }

  protected boolean actionPlay () {
    return false;
  }

  protected boolean actionPause () {
    return false;
  }

  protected boolean actionSuspend () {
    return false;
  }

  protected boolean actionResume () {
    return false;
  }

  protected boolean actionNext () {
    return false;
  }

  protected boolean actionPrevious () {
    return false;
  }

  public static enum Action {
    PLAY_PAUSE(
      new Performer() {
        @Override
        public boolean perform (RadioPlayer player) {
          return player.actionPlayPause();
        }
      }
    ),

    PLAY(
      new Performer() {
        @Override
        public boolean perform (RadioPlayer player) {
          return player.actionPlay();
        }
      }
    ),

    PAUSE(
      new Performer() {
        @Override
        public boolean perform (RadioPlayer player) {
          return player.actionPause();
        }
      }
    ),

    SUSPEND(
      new Performer() {
        @Override
        public boolean perform (RadioPlayer player) {
          return player.actionSuspend();
        }
      }
    ),

    RESUME(
      new Performer() {
        @Override
        public boolean perform (RadioPlayer player) {
          return player.actionResume();
        }
      }
    ),

    NEXT(
      new Performer() {
        @Override
        public boolean perform (RadioPlayer player) {
          return player.actionNext();
        }
      }
    ),

    PREVIOUS(
      new Performer() {
        @Override
        public boolean perform (RadioPlayer player) {
          return player.actionPrevious();
        }
      }
    ),

    ; // end of enumeration

    private static interface Performer {
      public boolean perform (RadioPlayer player);
    }

    private final Performer actionPerformer;

    Action (Performer performer) {
      actionPerformer = performer;
    }

    public final boolean perform () {
      synchronized (AUDIO_LOCK) {
        RadioPlayer player = getRadioPlayer();
        if (player == null) return false;
        return actionPerformer.perform(player);
      }
    }
  };

  public static interface OnFinishedListener {
    public void onFinished (RadioPlayer player);
  }

  private final Set<OnFinishedListener> onFinishedListeners = new LinkedHashSet<>();

  public final void addOnFinishedListener (OnFinishedListener listener) {
    onFinishedListeners.add(listener);
  }

  private long initialDelay = 0;
  private long baseDelay = 0;
  private double relativeDelay = 0d;
  private long maximumDelay = Long.MAX_VALUE;

  public final long getInitialDelay () {
    synchronized (this) {
      return initialDelay;
    }
  }

  public final RadioPlayer setInitialDelay (long milliseconds) {
    synchronized (this) {
      initialDelay = milliseconds;
      return this;
    }
  }

  public final RadioPlayer setInitialDelay (long count, TimeUnit unit) {
    return setInitialDelay(unit.toMillis(count));
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

  public void reset () {
    earliestTime = getCurrentTime() + initialDelay;
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

      for (OnFinishedListener listener : onFinishedListeners) {
        listener.onFinished(this);
      }

      if (RadioParameters.LOG_PLAYER_SCHEDULING) {
        Log.d(LOG_TAG, ("playing ended: " + getName()));
      }

      getProgram().onPlayerFinished(this);
    }
  }

  protected static void onRadioPlayerFinished (RadioPlayer player) {
    AudioFocus.abandonAudioFocus();
    if (ApiTests.HAVE_AudioAttributes) AudioFocus.setAudioAttributes(null);

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
