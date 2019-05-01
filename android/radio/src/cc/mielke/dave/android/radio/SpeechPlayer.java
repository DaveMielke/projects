package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.TextSpeaker;

import android.util.Log;

public abstract class SpeechPlayer extends RadioPlayer {
  private final static String LOG_TAG = SpeechPlayer.class.getName();

  private final static Object SPEECH_LOCK = new Object();
  private static SpeechViewer speechViewer = null;

  public static SpeechViewer getViewer () {
    synchronized (SPEECH_LOCK) {
      return speechViewer;
    }
  }

  public static void setViewer (SpeechViewer viewer) {
    synchronized (SPEECH_LOCK) {
      speechViewer = viewer;
    }
  }

  private static void onSpeechPlayerFinished (SpeechPlayer player) {
    synchronized (SPEECH_LOCK) {
      speechViewer.showText(null);
      onRadioPlayerFinished(player);
    }
  }

  private static void onSpeechPlayerFinished () {
    onSpeechPlayerFinished(null);
  }

  private final static TextSpeaker textSpeaker =
    new TextSpeaker(getContext(), RadioParameters.TTS_RETRY_DELAY) {
      @Override
      protected boolean getLogEvents () {
        return RadioParameters.LOG_SPEECH_PLAYER;
      }

      @Override
      protected void onSpeakingStarted (String identifier, CharSequence text) {
        speechViewer.showText(text);
      }

      @Override
      protected void onSpeakingFinished (String identifier) {
        onSpeechPlayerFinished();
      }
    };

  protected final boolean play (CharSequence text) {
    synchronized (SPEECH_LOCK) {
      logPlaying("speech", text);
      if (!textSpeaker.speakText(text)) return false;

      onPlayStart();
      return true;
    }
  }

  @Override
  public void stop () {
    try {
      if (RadioParameters.LOG_SPEECH_PLAYER) {
        Log.d(LOG_TAG, "stopping");
      }

      synchronized (SPEECH_LOCK) {
        textSpeaker.stopSpeaking();
      //onSpeechPlayerFinished(this);
      }
    } finally {
      super.stop();
    }
  }

  protected SpeechPlayer () {
    super();
  }
}
