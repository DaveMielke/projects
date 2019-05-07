package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.media.AudioManager;

public abstract class AudioComponent extends RadioComponent {
  private final static String LOG_TAG = AudioComponent.class.getName();

  protected AudioComponent () {
    super();
  }

  protected final static Object AUDIO_LOCK = new Object();
  protected final static AudioManager audioManager = getAudioManager();
}
