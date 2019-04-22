package cc.mielke.dave.android.radio;

import android.util.Log;

import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.os.Bundle;

public abstract class TextPlayer extends RadioPlayer {
  private final static String LOG_TAG = TextPlayer.class.getName();

  protected TextPlayer (RadioProgram program) {
    super(program);
  }

  private final static Object TTS_LOCK = new Object();
  private static TextToSpeech ttsObject = null;
  private static boolean ttsReady = false;
  private static int ttsMaximumInputLength = 0;
  private static int ttsUtteranceIdentifier = 0;
  private static RadioPlayer currentPlayer = null;

  private static void ttsDone () {
    synchronized (TTS_LOCK) {
      {
        RadioPlayer player = currentPlayer;
        currentPlayer = null;
        player.onPlayEnd();
      }
    }
  }

  private final static UtteranceProgressListener ttsUtteranceProgressListener =
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

  private static int getMaximumInputLength () {
    int length = 4000;

    try {
      length = ttsObject.getMaxSpeechInputLength();
    } catch (IllegalArgumentException exception) {
      Log.w(LOG_TAG, "get maximum TTS input length", exception);
    }

    return length - 1; // Android returns the wrong value
  }

  private static boolean ttsSpeak (String text) {
    if (ttsReady) {
      String utterance = Integer.toString(++ttsUtteranceIdentifier);
      Bundle parameters = new Bundle();

      int status = ttsObject.speak(
        text, TextToSpeech.QUEUE_FLUSH, parameters, utterance
      );

      if (status == TextToSpeech.SUCCESS) {
        return true;
      } else {
        Log.e(LOG_TAG, ("TTS speak failed: " + status));
      }
    } else {
      Log.w(LOG_TAG, "TTS not ready");
    }

    return false;
  }

  private final static TextToSpeech.OnInitListener ttsInitializationListener =
    new TextToSpeech.OnInitListener() {
      @Override
      public void onInit (int status) {
        synchronized (TTS_LOCK) {
          Log.d(LOG_TAG, ("TTS initialization status: " + status));

          switch (status) {
            case TextToSpeech.SUCCESS: {
              Log.d(LOG_TAG, "TTS initialized successfully");

              ttsObject.setOnUtteranceProgressListener(ttsUtteranceProgressListener);
              ttsMaximumInputLength = getMaximumInputLength();

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
                    ttsStart();
                  }
                }
              );

              break;
          }
        }
      }
    };

  private static void ttsStart () {
    synchronized (TTS_LOCK) {
      Log.d(LOG_TAG, "starting TTS");
      ttsObject = new TextToSpeech(getContext(), ttsInitializationListener);
    }
  }

  protected final boolean play (String text) {
    synchronized (TTS_LOCK) {
      logPlaying("text", text);
      currentPlayer = this;
      if (ttsSpeak(text)) return true;
      currentPlayer = null;
    }

    return false;
  }

  @Override
  public void stop () {
  // to-do
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
    ttsStart();
  }
}
