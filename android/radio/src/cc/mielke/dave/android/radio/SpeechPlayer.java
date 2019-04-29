package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.TextSpeaker;

import android.util.Log;

public abstract class SpeechPlayer extends RadioPlayer {
  private final static String LOG_TAG = SpeechPlayer.class.getName();

  private final static Object LOCK = new Object();
  private static SpeechViewer speechViewer = null;

  public static SpeechViewer getViewer () {
    synchronized (LOCK) {
      return speechViewer;
    }
  }

  public static void setViewer (SpeechViewer viewer) {
    synchronized (LOCK) {
      speechViewer = viewer;
    }
  }

  private static void ttsDone () {
    synchronized (LOCK) {
      speechViewer.showText(null);
      onPlayerDone();
    }
  }

  private final static TextSpeaker textSpeaker =
    new TextSpeaker(getContext(), RadioParameters.TTS_RETRY_DELAY) {
      @Override
      protected void onSpeakingStarted (String identifier, CharSequence text) {
        speechViewer.showText(text);
      }

      @Override
      protected void onSpeakingFinished (String identifier) {
        ttsDone();
      }
    };

  protected final boolean play (CharSequence text) {
    synchronized (LOCK) {
      logPlaying("speech", text);
      return textSpeaker.speakText(text);
    }
  }

  @Override
  public void stop () {
    try {
      synchronized (LOCK) {
        textSpeaker.stopSpeaking();
        ttsDone();
      }
    } finally {
      super.stop();
    }
  }

  protected SpeechPlayer () {
    super();
  }
}
