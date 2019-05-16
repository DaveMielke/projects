package cc.mielke.dave.android.radio;

import android.util.Log;

import cc.mielke.dave.android.base.ApiTests;
import cc.mielke.dave.android.base.StreamPlayer;
import cc.mielke.dave.android.base.AndroidMediaPlayer;
import android.media.AudioAttributes;
import android.net.Uri;

public abstract class UriPlayer extends RadioPlayer {
  private final static String LOG_TAG = UriPlayer.class.getName();

  protected UriPlayer () {
    super();
  }

  private final static UriWatcher uriWatcher = new UriWatcher();;

  public static UriWatcher getWatcher () {
    return uriWatcher;
  }

  private static void onUriPlayerFinished (UriPlayer player) {
    synchronized (AUDIO_LOCK) {
      PositionMonitor.StopReason.INACTIVE.stop();
      PositionMonitor.StopReason.PAUSE.start();

      uriWatcher.onUriChange(null);
      uriWatcher.onPlayPauseChange(null);
      uriWatcher.onDurationChange(0);
      uriWatcher.onPositionChange(0);

      onRadioPlayerFinished(player);
    }
  }

  private static void onUriPlayerFinished () {
    onUriPlayerFinished(null);
  }

  private static boolean requestAudioFocus () {
    return AudioFocus.requestAudioFocus(false);
  }

  private final static StreamPlayer streamPlayer =
    new AndroidMediaPlayer(getContext()) {
      @Override
      protected boolean getLogEvents () {
        return RadioParameters.LOG_URI_PLAYER;
      }

      @Override
      protected boolean onPlayerStart () {
        synchronized (AUDIO_LOCK) {
          uriWatcher.onPlayPauseChange(true);
          uriWatcher.onDurationChange(streamPlayer.getDuration());
          uriWatcher.onPositionChange(0);

          if (requestAudioFocus()) {
            PositionMonitor.StopReason.INACTIVE.start();
            return true;
          } else {
            onUriPlayerFinished();
          }

          return false;
        }
      }

      @Override
      protected void onPlayerFinished () {
        synchronized (AUDIO_LOCK) {
          onUriPlayerFinished();
        }
      }
    };

  public static int getPosition () {
    synchronized (AUDIO_LOCK) {
      return streamPlayer.getPosition();
    }
  }

  public static void setPosition (int milliseconds) {
    synchronized (AUDIO_LOCK) {
      streamPlayer.setPosition(milliseconds);
    }
  }

  protected final boolean play (Uri uri, int audioContentType) {
    if (uri == null) return false;
    logPlaying("URI", uri.toString());

    synchronized (AUDIO_LOCK) {
      if (!streamPlayer.setSource(uri)) return false;

      if (ApiTests.HAVE_AudioAttributes) {
        AudioAttributes attributes = new AudioAttributes.Builder()
          .setUsage(AudioAttributes.USAGE_MEDIA)
          .setContentType(audioContentType)
          .build();

        AudioFocus.setAudioAttributes(attributes);
        streamPlayer.setAudioAttributes(attributes);
      }

      onPlayStart();
      uriWatcher.onUriChange(uri);
      streamPlayer.start();
      return true;
    }
  }

  @Override
  public void stop () {
    try {
      if (RadioParameters.LOG_URI_PLAYER) {
        Log.d(LOG_TAG, "stopping");
      }

      synchronized (AUDIO_LOCK) {
        streamPlayer.stop();
        onUriPlayerFinished(this);
      }
    } finally {
      super.stop();
    }
  }

  private final void suspendPlayer (boolean pause) {
    if (streamPlayer.isPlaying()) {
      streamPlayer.suspend();
      PositionMonitor.StopReason.PAUSE.stop();
    }

    if (pause) {
      uriWatcher.onPlayPauseChange(false);
      AudioFocus.abandonAudioFocus();
    }
  }

  private final boolean resumePlayer (boolean isPaused) {
    if (isPaused) {
      if (streamPlayer.isPlaying()) {
        throw new IllegalStateException("playing without audio focus");
      }

      if (!requestAudioFocus()) return false;
      uriWatcher.onPlayPauseChange(true);
    }

    streamPlayer.resume();
    PositionMonitor.StopReason.PAUSE.start();
    return true;
  }

  @Override
  protected final boolean actionPlayPause () {
    synchronized (AUDIO_LOCK) {
      if (!AudioFocus.isAudioFocusActive()) return resumePlayer(true);
      suspendPlayer(true);
      return true;
    }
  }

  @Override
  protected final boolean actionPlay () {
    synchronized (AUDIO_LOCK) {
      if (AudioFocus.isAudioFocusActive()) return false;
      return resumePlayer(true);
    }
  }

  @Override
  protected final boolean actionPause () {
    synchronized (AUDIO_LOCK) {
      if (!AudioFocus.isAudioFocusActive()) return false;
      suspendPlayer(true);
      return true;
    }
  }

  @Override
  protected final boolean actionSuspend () {
    synchronized (AUDIO_LOCK) {
      if (!AudioFocus.isAudioFocusActive()) return false;
      if (!streamPlayer.isPlaying()) return false;
      suspendPlayer(false);
      return true;
    }
  }

  @Override
  protected final boolean actionResume () {
    synchronized (AUDIO_LOCK) {
      if (!AudioFocus.isAudioFocusActive()) return false;
      if (streamPlayer.isPlaying()) return false;
      return resumePlayer(false);
    }
  }
}
