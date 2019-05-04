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

  protected final static Object AUDIO_LOCK = new Object();
  protected final static AudioManager audioManager = getAudioManager();

  private static AudioAttributes audioAttributes = null;
  private static AudioFocusRequest audioFocusRequest = null;
  private static boolean haveAudioFocus = false;

  protected static void setAudioAttributes (AudioAttributes attributes) {
    synchronized (AUDIO_LOCK) {
      audioAttributes = attributes;
    }
  }

  private final static AudioManager.OnAudioFocusChangeListener audioFocusChangeListener =
    new AudioManager.OnAudioFocusChangeListener() {
      @Override
      public void onAudioFocusChange (int change) {
        synchronized (AUDIO_LOCK) {
          switch (change) {
            case AudioManager.AUDIOFOCUS_GAIN: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus regained");
              }

              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus permanently lost");
              }

              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus temporarily lost (may not duck)");
              }

              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus temporarily lost (may duck)");
              }

              break;
            }

            default:
              Log.w(LOG_TAG, ("unexpected audio focus change: " + change));
              break;
          }
        }
      }
    };

  protected static boolean requestAudioFocus (boolean temporary) {
    if (RadioParameters.LOG_AUDIO_FOCUS) {
      Log.d(LOG_TAG,
        String.format(
          "requesting %s audio focus",
          (temporary? "temporary": "persistent")
        )
      );
    }

    synchronized (AUDIO_LOCK) {
      if (haveAudioFocus) {
        throw new IllegalStateException("already have audio focus");
      }

      if (ApiTests.HAVE_AudioAttributes) {
        if (audioAttributes == null) {
          throw new IllegalStateException("no audio attributes");
        }
      }

      int how = temporary? AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK: AudioManager.AUDIOFOCUS_GAIN;
      int stream = AudioManager.STREAM_MUSIC;
      int result;

      if (ApiTests.HAVE_AudioFocusRequest) {
        if (audioFocusRequest != null) {
          throw new IllegalStateException("already have audio focus request");
        }

        audioFocusRequest = new AudioFocusRequest
          .Builder(how)
          .setAudioAttributes(audioAttributes)
          .build();

        result = audioManager.requestAudioFocus(audioFocusRequest);
      } else {
        result = audioManager.requestAudioFocus(audioFocusChangeListener, stream, how);
      }

      if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
        if (RadioParameters.LOG_AUDIO_FOCUS) {
          Log.d(LOG_TAG, "audio focus granted");
        }

        haveAudioFocus = true;
        return true;
      }

      Log.w(LOG_TAG, ("audio focus not granted: " + result));
      return false;
    }
  }

  protected static void abandonAudioFocus () {
    if (RadioParameters.LOG_AUDIO_FOCUS) {
      Log.d(LOG_TAG, "abandoning audio focus");
    }

    synchronized (AUDIO_LOCK) {
      if (haveAudioFocus) {
        int result;

        if (ApiTests.HAVE_AudioFocusRequest) {
          result = audioManager.abandonAudioFocusRequest(audioFocusRequest);
          audioFocusRequest = null;
        } else {
          result = audioManager.abandonAudioFocus(audioFocusChangeListener);
        }

        if (result != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
          Log.w(LOG_TAG, ("unexpected abandon audio focus result: " + result));
        }

        haveAudioFocus = false;
      } else if (RadioParameters.LOG_AUDIO_FOCUS) {
        Log.d(LOG_TAG, "audio focus not held");
      }

      if (ApiTests.HAVE_AudioAttributes) audioAttributes = null;
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
