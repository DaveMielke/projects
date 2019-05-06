package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.media.AudioManager;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;

public abstract class AudioComponent extends RadioComponent {
  private final static String LOG_TAG = AudioComponent.class.getName();

  protected AudioComponent () {
    super();
  }

  protected final static AudioManager audioManager = getAudioManager();
  protected final static Object AUDIO_LOCK = new Object();

  protected boolean actionPlayPause () {
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

  private static AudioAttributes audioAttributes = null;
  private static AudioFocusRequest audioFocusRequest = null;
  private static boolean haveAudioFocus = false;

  protected static void setAudioAttributes (AudioAttributes attributes) {
    synchronized (AUDIO_LOCK) {
      audioAttributes = attributes;
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

              Action.RESUME.perform();
              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus permanently lost");
              }

              Action.SUSPEND.perform();
              abandonAudioFocus();
              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus temporarily lost (may not duck)");
              }

              Action.SUSPEND.perform();
              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus temporarily lost (may duck)");
              }

              Action.SUSPEND.perform();
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

        audioFocusRequest = new AudioFocusRequest.Builder(how)
          .setAudioAttributes(audioAttributes)
          .setOnAudioFocusChangeListener(audioFocusChangeListener)
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
}
