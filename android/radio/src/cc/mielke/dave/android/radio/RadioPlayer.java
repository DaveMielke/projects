package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.LinkedHashSet;

import java.util.concurrent.TimeUnit;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.media.AudioManager;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;

public abstract class RadioPlayer extends RadioComponent {
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

  protected final static AudioManager audioManager = getAudioManager();
  private static AudioAttributes audioAttributes = null;

  protected static void setAudioAttributes (AudioAttributes attributes) {
    audioAttributes = attributes;
  }

  private final static AudioManager.OnAudioFocusChangeListener audioFocusChangeListener =
    new AudioManager.OnAudioFocusChangeListener() {
      @Override
      public void onAudioFocusChange (int change) {
        synchronized (AUDIO_FOCUS_LOCK) {
          switch (change) {
            case AudioManager.AUDIOFOCUS_GAIN:
              break;

            case AudioManager.AUDIOFOCUS_LOSS:
              break;

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
              break;

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
              break;

            default:
              Log.w(LOG_TAG, ("unexpected audio focus change: " + change));
              break;
          }
        }
      }
    };

  private final static Object AUDIO_FOCUS_LOCK = new Object();
  private static AudioFocusRequest audioFocusRequest = null;

  protected static boolean requestAudioFocus (boolean brief) {
    synchronized (AUDIO_FOCUS_LOCK) {
      int how = brief? AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK: AudioManager.AUDIOFOCUS_GAIN;
      int stream = AudioManager.STREAM_MUSIC;
      int result;

      if (ApiTests.HAVE_AudioFocusRequest) {
        audioFocusRequest = new AudioFocusRequest
          .Builder(how)
          .setAudioAttributes(audioAttributes)
          .build();

        result = audioManager.requestAudioFocus(audioFocusRequest);
      } else {
        result = audioManager.requestAudioFocus(audioFocusChangeListener, stream, how);
      }

      if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) return true;
      Log.w(LOG_TAG, "audio focus not granted");
      return false;
    }
  }

  protected static void requestAudioFocus () {
    requestAudioFocus(false);
  }

  private static void abandonAudioFocus () {
    synchronized (AUDIO_FOCUS_LOCK) {
      int result;

      if (ApiTests.HAVE_AudioFocusRequest) {
        result = audioManager.abandonAudioFocusRequest(audioFocusRequest);
        audioFocusRequest = null;
      } else {
        result = audioManager.abandonAudioFocus(audioFocusChangeListener);
      }
    }
  }

  public static interface OnFinishedListener {
    public void onFinished (RadioPlayer player);
  }

  private final Set<OnFinishedListener> onFinishedListeners = new LinkedHashSet<>();

  public final void addOnFinishedListener (OnFinishedListener listener) {
    onFinishedListeners.add(listener);
  }

  private long baseDelay = 0;
  private double relativeDelay = 0d;
  private long maximumDelay = Long.MAX_VALUE;

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
    abandonAudioFocus();

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
