package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.media.AudioManager;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;

public abstract class AudioFocus extends AudioComponent {
  private final static String LOG_TAG = AudioFocus.class.getName();

  private AudioFocus () {
  }

  private static AudioAttributes audioAttributes = null;
  private static AudioFocusRequest audioFocusRequest = null;
  private static boolean audioFocusActive = false;

  protected static void setAudioAttributes (AudioAttributes attributes) {
    synchronized (AUDIO_LOCK) {
      audioAttributes = attributes;
    }
  }

  protected static boolean isAudioFocusActive () {
    return audioFocusActive;
  }

  protected static void abandonAudioFocus () {
    if (RadioParameters.LOG_AUDIO_FOCUS) {
      Log.d(LOG_TAG, "abandoning audio focus");
    }

    synchronized (AUDIO_LOCK) {
      if (audioFocusActive) {
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

        audioFocusActive = false;
      } else if (RadioParameters.LOG_AUDIO_FOCUS) {
        Log.d(LOG_TAG, "audio focus not held");
      }
    }
  }

  private static void onAudioFocusGained () {
    RadioPlayer.Action.RESUME.perform();
  }

  private static void onAudioFocusTemporarilyLost () {
    RadioPlayer.Action.SUSPEND.perform();
  }

  private static void onAudioFocusPermanentlyLost () {
    RadioPlayer.Action.PAUSE.perform();
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

              onAudioFocusGained();
              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus permanently lost");
              }

              onAudioFocusPermanentlyLost();
              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus temporarily lost (may not duck)");
              }

              onAudioFocusTemporarilyLost();
              break;
            }

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK: {
              if (RadioParameters.LOG_AUDIO_FOCUS) {
                Log.d(LOG_TAG, "audio focus temporarily lost (may duck)");
              }

              onAudioFocusTemporarilyLost();
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
      if (audioFocusActive) {
        throw new IllegalStateException("audio focus already active");
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

        audioFocusActive = true;
        return true;
      }

      Log.w(LOG_TAG, ("audio focus not granted: " + result));
      return false;
    }
  }
}
