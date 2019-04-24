package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;

import android.os.Bundle;
import java.util.HashMap;

import android.media.AudioManager;
import android.media.AudioAttributes;

public abstract class TextPlayer extends RadioPlayer {
  private final static String LOG_TAG = TextPlayer.class.getName();

  protected TextPlayer (RadioProgram program) {
    super(program);
  }

  private final static Object TTS_LOCK = new Object();
  private static TextToSpeech ttsObject = null;
  private static boolean ttsReady = false;

  private final static boolean useNewParadigm = ApiTests.haveLollipop;
  private static Bundle newParameters = null;
  private static HashMap<String, String> oldParameters = null;

  static {
    if (useNewParadigm) {
      newParameters = new Bundle();
    } else {
      oldParameters = new HashMap<String, String>();
    }
  }

  private static int maximumInputLength = 0;
  private static int utteranceIdentifier = 0;

  private static RadioPlayer currentPlayer = null;

  private static void ttsDone () {
    synchronized (TTS_LOCK) {
      if (currentPlayer != null) {
        RadioPlayer player = currentPlayer;
        currentPlayer = null;
        player.onPlayEnd();
      } else {
        Log.w(LOG_TAG, "no current player");
      }
    }
  }

  private final static UtteranceProgressListener utteranceProgressListener =
    new UtteranceProgressListener() {
      @Override
      public void onStart (String identifier) {
        Log.d(LOG_TAG, ("utterance generation starting: " + identifier));
      }

      @Override
      public void onError (String identifier) {
        Log.w(LOG_TAG, ("utterance generation failed: " + identifier));
        ttsDone();
      }

      @Override
      public void onError (String identifier, int error) {
        Log.w(LOG_TAG,
          String.format(
            "utterance generation error %d: %s",
            error, identifier
          )
        );

        ttsDone();
      }

      @Override
      public void onStop (String identifier, boolean interrupted) {
        Log.w(LOG_TAG, 
          String.format(
            "utterance generation %s: %s",
            (interrupted? "interrupted": "stopped"), identifier
          )
        );

        ttsDone();
      }

      @Override
      public void onDone (String identifier) {
        Log.d(LOG_TAG, ("utterance generation done: " + identifier));
        ttsDone();
      }
    };

  private static boolean isEngineStarted () {
    if (ttsReady) return true;
    Log.w(LOG_TAG, "TTS not ready");
    return false;
  }

  private static int getMaximumInputLength () {
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

  private static boolean setParameter (String key, String value) {
    if (useNewParadigm) {
      newParameters.putString(key, value);
    } else {
      oldParameters.put(key, value);
    }

    return true;
  }

  private static boolean setParameter (String key, int value) {
    return setParameter(key, Integer.toString(value));
  }

  private static boolean setParameter (String key, float value) {
    return setParameter(key, Float.toString(value));
  }

  private static boolean setStream (int value) {
    synchronized (TTS_LOCK) {
      return setParameter(TextToSpeech.Engine.KEY_PARAM_STREAM, value);
    }
  }

  private static boolean setStream () {
    return setStream(TextToSpeech.Engine.DEFAULT_STREAM);
  }

  private static boolean setVolume (float value) {
    synchronized (TTS_LOCK) {
      return setParameter(TextToSpeech.Engine.KEY_PARAM_VOLUME, value);
    }
  }

  private static boolean setBalance (float value) {
    synchronized (TTS_LOCK) {
      return setParameter(TextToSpeech.Engine.KEY_PARAM_PAN, value);
    }
  }

  private static boolean setRate (float value) {
    synchronized (TTS_LOCK) {
      if (!isEngineStarted()) return false;
      return ttsObject.setSpeechRate(value) == TextToSpeech.SUCCESS;
    }
  }

  private static boolean setPitch (float value) {
    synchronized (TTS_LOCK) {
      if (!isEngineStarted()) return false;
      return ttsObject.setPitch(value) == TextToSpeech.SUCCESS;
    }
  }

  private static boolean speakText (String text) {
    if (isEngineStarted()) {
      int queueMode = TextToSpeech.QUEUE_FLUSH;
      String utterance = Integer.toString(++utteranceIdentifier);
      int status;

      if (useNewParadigm) {
        status = ttsObject.speak(text, queueMode, newParameters, utterance);
      } else {
        setParameter(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, utterance);
        status = ttsObject.speak(text, queueMode, oldParameters);
      }

      if (status == TextToSpeech.SUCCESS) {
        return true;
      } else {
        Log.e(LOG_TAG, ("TTS speak failed: " + status));
      }
    }

    return false;
  }

  private final static TextToSpeech.OnInitListener initializationListener =
    new TextToSpeech.OnInitListener() {
      @Override
      public void onInit (int status) {
        synchronized (TTS_LOCK) {
          Log.d(LOG_TAG, ("TTS initialization status: " + status));

          switch (status) {
            case TextToSpeech.SUCCESS: {
              Log.d(LOG_TAG, "TTS initialized successfully");

              ttsObject.setOnUtteranceProgressListener(utteranceProgressListener);
              maximumInputLength = getMaximumInputLength();

              if (ApiTests.haveLollipop) {
                AudioAttributes.Builder builder = new AudioAttributes.Builder();
                builder.setUsage(AudioAttributes.USAGE_NOTIFICATION);
                builder.setContentType(AudioAttributes.CONTENT_TYPE_SPEECH);
                builder.setFlags(AudioAttributes.FLAG_AUDIBILITY_ENFORCED);
                ttsObject.setAudioAttributes(builder.build());
              } else {
                setStream(AudioManager.STREAM_NOTIFICATION);
              }

              setVolume(1.0f);
              setBalance(0.0f);
              setRate(1.0f);
              setPitch(1.0f);

              ttsReady = true;
              break;
            }

            default:
              Log.d(LOG_TAG, ("unexpected TTS initialization status: " + status));
              /* fall through */
            case TextToSpeech.ERROR:
              Log.w(LOG_TAG, "TTS failed to initialize");
              ttsObject = null;

              post(
                RadioParameters.TTS_RETRY_DELAY,
                new Runnable() {
                  @Override
                  public void run () {
                    startEngine();
                  }
                }
              );

              break;
          }
        }
      }
    };

  private static void startEngine () {
    synchronized (TTS_LOCK) {
      Log.d(LOG_TAG, "starting TTS");
      ttsObject = new TextToSpeech(getContext(), initializationListener);
    }
  }

  protected final boolean play (String text) {
    synchronized (TTS_LOCK) {
      logPlaying("text", text);
      currentPlayer = this;
      if (speakText(text)) return true;
      currentPlayer = null;
    }

    return false;
  }

  @Override
  public void stop () {
    try {
      synchronized (TTS_LOCK) {
        if (ttsObject != null) {
          ttsObject.stop();
          ttsDone();
        }
      }
    } finally {
      super.stop();
    }
  }

  static {
    startEngine();
  }
}
