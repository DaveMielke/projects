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

  private static void onSpeechPlayerFinished () {
    synchronized (SPEECH_LOCK) {
      speechViewer.showText(null);
      onRadioPlayerFinished();
    }
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
      return textSpeaker.speakText(text);
    }
  }

  @Override
  public void stop () {
    try {
      synchronized (SPEECH_LOCK) {
        textSpeaker.stopSpeaking();
        onSpeechPlayerFinished();
      }
    } finally {
      super.stop();
    }
  }

  protected SpeechPlayer () {
    super();
  }
}
