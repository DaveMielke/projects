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

  private static int getMaximumInputLength (TextToSpeech tts) {
    int length = 4000;

    try {
      length = tts.getMaxSpeechInputLength();
    } catch (IllegalArgumentException exception) {
      Log.w(LOG_TAG, "get maximum TTS input length", exception);
    }

    return length - 1; // Android returns the wrong value
  }

  private static boolean ttsStart () {
    synchronized (TTS_LOCK) {
      if (ttsObject != null) return true;

      class Listener implements TextToSpeech.OnInitListener {
        public int initializationStatus = TextToSpeech.ERROR;

        @Override
        public void onInit (int status) {
          synchronized (this) {
            Log.d(LOG_TAG, ("TTS initialization status: " + status));
            initializationStatus = status;
            notify();
          }
        }
      }

      Log.d(LOG_TAG, "starting TTS");
      Listener listener = new Listener();
      TextToSpeech tts;

      synchronized (listener) {
        tts = new TextToSpeech(getContext(), listener);

        try {
          Log.d(LOG_TAG, "waiting for TTS initialization");
          listener.wait();
        } catch (InterruptedException exception) {
          Log.w(LOG_TAG, "TTS initialization wait interrupted");
        }
      }

      switch (listener.initializationStatus) {
        case TextToSpeech.SUCCESS: {
          Log.d(LOG_TAG, "TTS initialized successfully");
          tts.setOnUtteranceProgressListener(ttsUtteranceProgressListener);

          ttsMaximumInputLength = getMaximumInputLength(tts);
          ttsObject = tts;
          return true;
        }

        default:
          Log.d(LOG_TAG, ("unexpected TTS initialization status: " + listener.initializationStatus));
          /* fall through */
        case TextToSpeech.ERROR:
          Log.w(LOG_TAG, "TTS failed to initialize");
          return false;
      }
    }
  }

  protected final boolean play (String text) {
    if (!ttsStart()) return false;
    logPlaying("text", text);

    synchronized (TTS_LOCK) {
      currentPlayer = this;

      String utterance = Integer.toString(++ttsUtteranceIdentifier);
      Bundle parameters = new Bundle();

      int status = ttsObject.speak(
        text, TextToSpeech.QUEUE_FLUSH, parameters, utterance
      );

      if (status == TextToSpeech.SUCCESS) return true;
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
          ttsObject.shutdown();
          ttsDone();
        }
      }
    } finally {
      super.stop();
    }
  }
}
