package cc.mielke.dave.android.base;

import android.util.Log;
import android.content.Context;
import android.os.Handler;

import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;

import android.os.Bundle;
import java.util.HashMap;

import android.media.AudioManager;
import android.media.AudioAttributes;

public class TextSpeaker {
  private final static String LOG_TAG = TextSpeaker.class.getName();

  protected boolean getLogEvents () {
    return false;
  }

  protected void onStartSpeaking (String identifier, CharSequence text) {
  }

  protected void onSpeakingFinished (String identifier) {
  }

  private final static AudioAttributes audioAttributes;

  static {
    if (ApiTests.HAVE_AudioAttributes) {
      audioAttributes = new AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
        .setFlags(AudioAttributes.FLAG_AUDIBILITY_ENFORCED)
        .build();
    } else {
      audioAttributes = null;
    }
  }

  public static AudioAttributes getAudioAttributes () {
    return audioAttributes;
  }

  private final Context ttsContext;
  private final long ttsRetryDelay;
  private final Handler ttsHandler;

  private TextToSpeech ttsObject = null;
  private boolean ttsReady = false;

  private final UtteranceProgressListener utteranceProgressListener =
    new UtteranceProgressListener() {
      @Override
      public void onStart (String identifier) {
        if (getLogEvents()) {
          Log.d(LOG_TAG, ("utterance generation starting: " + identifier));
        }
      }

      @Override
      public void onError (String identifier) {
        Log.e(LOG_TAG, ("utterance generation failed: " + identifier));
        onSpeakingFinished(identifier);
      }

      @Override
      public void onError (String identifier, int error) {
        Log.e(LOG_TAG,
          String.format(
            "utterance generation error %d: %s",
            error, identifier
          )
        );

        onSpeakingFinished(identifier);
      }

      @Override
      public void onStop (String identifier, boolean interrupted) {
        Log.w(LOG_TAG, 
          String.format(
            "utterance generation %s: %s",
            (interrupted? "interrupted": "stopped"), identifier
          )
        );

        onSpeakingFinished(identifier);
      }

      @Override
      public void onDone (String identifier) {
        if (getLogEvents()) {
          Log.d(LOG_TAG, ("utterance generation done: " + identifier));
        }

        onSpeakingFinished(identifier);
      }
    };

  private final boolean isEngineStarted () {
    if (ttsReady) return true;
    Log.w(LOG_TAG, "TTS not ready");
    return false;
  }

  private final boolean USE_BUNDLED_PARAMETERS = ApiTests.haveLollipop;
  private Bundle newParameters = null;
  private HashMap<String, String> oldParameters = null;

  private final void setOldParameter (String key, String value) {
    oldParameters.put(key, value);
  }

  private final void setParameter (String key, String value) {
    if (USE_BUNDLED_PARAMETERS) {
      newParameters.putString(key, value);
    } else {
      setOldParameter(key, value);
    }
  }

  private final void setParameter (String key, int value) {
    if (USE_BUNDLED_PARAMETERS) {
      newParameters.putInt(key, value);
    } else {
      setOldParameter(key, Integer.toString(value));
    }
  }

  private final void setParameter (String key, float value) {
    if (USE_BUNDLED_PARAMETERS) {
      newParameters.putFloat(key, value);
    } else {
      setOldParameter(key, Float.toString(value));
    }
  }

  private final boolean setStream (int value) {
    synchronized (this) {
      setParameter(TextToSpeech.Engine.KEY_PARAM_STREAM, value);
      return true;
    }
  }

  private final boolean setStream () {
    return setStream(TextToSpeech.Engine.DEFAULT_STREAM);
  }

  public final static float VOLUME_MINIMUM = 0f;
  public final static float VOLUME_MAXIMUM = 1f;

  public final static float VOLUME_DEFAULT = VOLUME_MAXIMUM;
  private float currentVolume = VOLUME_DEFAULT;

  public final float getVolume () {
    synchronized (this) {
      return currentVolume;
    }
  }

  public final boolean setVolume (float value) {
    synchronized (this) {
      if (value < VOLUME_MINIMUM) return false;
      if (value > VOLUME_MAXIMUM) return false;

      setParameter(TextToSpeech.Engine.KEY_PARAM_VOLUME, value);
      currentVolume = value;
      return true;
    }
  }

  public final static float BALANCE_CENTER = 0f;
  public final static float BALANCE_RIGHT = 1f;
  public final static float BALANCE_LEFT = -BALANCE_RIGHT;

  public final static float BALANCE_DEFAULT = BALANCE_CENTER;
  private float currentBalance = BALANCE_DEFAULT;

  public final float getBalance () {
    synchronized (this) {
      return currentBalance;
    }
  }

  public final boolean setBalance (float value) {
    synchronized (this) {
      if (value < BALANCE_LEFT) return false;
      if (value > BALANCE_RIGHT) return false;

      setParameter(TextToSpeech.Engine.KEY_PARAM_PAN, value);
      currentBalance = value;
      return true;
    }
  }

  public final static float RATE_MAXIMUM = 10f;
  public final static float RATE_MINIMUM = 1f / RATE_MAXIMUM;

  public final static float RATE_DEFAULT = 1f;
  private float currentRate = RATE_DEFAULT;

  public final float getRate () {
    synchronized (this) {
      return currentRate;
    }
  }

  public final boolean setRate (float value) {
    synchronized (this) {
      if (value < RATE_MINIMUM) return false;
      if (value > RATE_MAXIMUM) return false;

      if (!isEngineStarted()) return false;
      if (ttsObject.setSpeechRate(value) != TextToSpeech.SUCCESS) return false;

      currentRate = value;
      return true;
    }
  }

  public final static float PITCH_MAXIMUM = 10f;
  public final static float PITCH_MINIMUM = 1f / PITCH_MAXIMUM;

  public final static float PITCH_DEFAULT = 1f;
  private float currentPitch = PITCH_DEFAULT;

  public final float getPitch () {
    synchronized (this) {
      return currentPitch;
    }
  }

  public final boolean setPitch (float value) {
    synchronized (this) {
      if (value < PITCH_MINIMUM) return false;
      if (value > PITCH_MAXIMUM) return false;

      if (!isEngineStarted()) return false;
      if (ttsObject.setPitch(value) != TextToSpeech.SUCCESS) return false;

      currentPitch = value;
      return true;
    }
  }

  private int maximumInputLength = 0;
  private int utteranceIdentifier = 0;

  public final boolean speakText (CharSequence text, boolean flush) {
    if (isEngineStarted()) {
      int queueMode = flush? TextToSpeech.QUEUE_FLUSH: TextToSpeech.QUEUE_ADD;
      String identifier = Integer.toString(++utteranceIdentifier);
      int status;

      onStartSpeaking(identifier, text);

      if (USE_BUNDLED_PARAMETERS) {
        status = ttsObject.speak(text, queueMode, newParameters, identifier);
      } else {
        setParameter(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, identifier);
        status = ttsObject.speak(text.toString(), queueMode, oldParameters);
      }

      if (status == TextToSpeech.SUCCESS) return true;
      Log.e(LOG_TAG, ("TTS speak failed: " + status));
      onSpeakingFinished(identifier);
    }

    return false;
  }

  public final boolean speakText (CharSequence text) {
    return speakText(text, true);
  }

  public boolean stopSpeaking () {
    synchronized (this) {
      if (isEngineStarted()) {
        int status = ttsObject.stop();

        if (status == TextToSpeech.SUCCESS) {
          return true;
        } else {
          Log.e(LOG_TAG, ("TTS stop failed: " + status));
        }
      }
    }

    return false;
  }

  public boolean isSpeaking () {
    synchronized (this) {
      if (!isEngineStarted()) return false;
      return ttsObject.isSpeaking();
    }
  }

  private int getMaximumInputLength () {
    int length = 4000;

    if (ApiTests.haveJellyBeanMR2) {
      try {
        length = ttsObject.getMaxSpeechInputLength();
      } catch (IllegalArgumentException exception) {
        Log.w(LOG_TAG, "can't get maximum TTS input length", exception);
      }
    }

    return length - 1; // Android returns the wrong value
  }

  private final TextToSpeech.OnInitListener initializationListener =
    new TextToSpeech.OnInitListener() {
      @Override
      public void onInit (int status) {
        if (getLogEvents()) {
          Log.d(LOG_TAG, ("TTS initialization status: " + status));
        }

        synchronized (TextSpeaker.this) {
          switch (status) {
            case TextToSpeech.SUCCESS: {
              if (getLogEvents()) {
                Log.d(LOG_TAG, "TTS initialized successfully");
              }

              ttsObject.setOnUtteranceProgressListener(utteranceProgressListener);
              maximumInputLength = getMaximumInputLength();
              ttsReady = true;

              if (ApiTests.HAVE_AudioAttributes) {
                ttsObject.setAudioAttributes(audioAttributes);
              } else {
                setStream(AudioManager.STREAM_MUSIC);
              }

              setVolume(VOLUME_MAXIMUM);
              setBalance(BALANCE_CENTER);
              setRate(1f);
              setPitch(1f);

              break;
            }

            default:
              Log.w(LOG_TAG, ("unexpected TTS initialization status: " + status));
              /* fall through */
            case TextToSpeech.ERROR:
              Log.e(LOG_TAG, "TTS failed to initialize");
              ttsObject = null;

              Runnable retry =
                new Runnable() {
                  @Override
                  public void run () {
                    startEngine();
                  }
                };

              ttsHandler.postDelayed(retry, ttsRetryDelay);
              break;
          }
        }
      }
    };

  private final void startEngine () {
    synchronized (this) {
      if (getLogEvents()) {
        Log.d(LOG_TAG, "starting TTS");
      }

      ttsObject = new TextToSpeech(ttsContext, initializationListener);
    }
  }

  public TextSpeaker (Context context, long retryDelay) {
    super();

    ttsContext = context;
    ttsRetryDelay = retryDelay;
    ttsHandler = new Handler();

    if (USE_BUNDLED_PARAMETERS) {
      newParameters = new Bundle();
    } else {
      oldParameters = new HashMap<String, String>();
    }

    startEngine();
  }
}
