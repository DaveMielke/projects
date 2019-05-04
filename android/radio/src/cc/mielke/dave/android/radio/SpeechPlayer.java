package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.TextSpeaker;

import android.util.Log;

import android.media.AudioAttributes;

public abstract class SpeechPlayer extends RadioPlayer {
  private final static String LOG_TAG = SpeechPlayer.class.getName();

  protected SpeechPlayer () {
    super();
  }

  private static SpeechViewer speechViewer = null;

  public static void setViewer (SpeechViewer viewer) {
    synchronized (AUDIO_LOCK) {
      speechViewer = viewer;
    }
  }

  private static void onSpeechPlayerFinished (SpeechPlayer player) {
    synchronized (AUDIO_LOCK) {
      speechViewer.showText(null);
      onRadioPlayerFinished(player);
    }
  }

  private static void onSpeechPlayerFinished () {
    onSpeechPlayerFinished(null);
  }

  private static boolean requestAudioFocus () {
    return requestAudioFocus(true);
  }

  private final static TextSpeaker textSpeaker =
    new TextSpeaker(getContext(), RadioParameters.TTS_RETRY_DELAY) {
      @Override
      protected boolean getLogEvents () {
        return RadioParameters.LOG_SPEECH_PLAYER;
      }

      @Override
      protected void onSetAudioAttributes (AudioAttributes attributes) {
        setAudioAttributes(attributes);
      }

      @Override
      protected void onStartSpeaking (String identifier, CharSequence text) {
        speechViewer.showText(text);
      }

      @Override
      protected void onSpeakingFinished (String identifier) {
        onSpeechPlayerFinished();
      }
    };

  protected final boolean play (CharSequence text) {
    synchronized (AUDIO_LOCK) {
      logPlaying("speech", text);
      onPlayStart();

      if (requestAudioFocus()) {
        if (textSpeaker.speakText(text, true)) {
          return true;
        }
      }

      onSpeechPlayerFinished(this);
      return false;
    }
  }

  @Override
  public void stop () {
    try {
      if (RadioParameters.LOG_SPEECH_PLAYER) {
        Log.d(LOG_TAG, "stopping");
      }

      synchronized (AUDIO_LOCK) {
        textSpeaker.stopSpeaking();
      //onSpeechPlayerFinished(this);
      }
    } finally {
      super.stop();
    }
  }
}
