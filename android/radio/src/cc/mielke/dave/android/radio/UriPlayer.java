package cc.mielke.dave.android.radio;

import java.io.IOException;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.media.MediaPlayer;
import android.media.AudioAttributes;
import android.net.Uri;

public abstract class UriPlayer extends RadioPlayer {
  private final static String LOG_TAG = UriPlayer.class.getName();

  protected UriPlayer () {
    super();
  }

  private static UriViewer uriViewer = new UriViewer();;
  private static MediaPlayer mediaPlayer = new MediaPlayer();

  public static UriViewer getViewer () {
    return uriViewer;
  }

  private static void onUriPlayerFinished (UriPlayer player) {
    synchronized (AUDIO_LOCK) {
      PositionMonitor.stop(PositionMonitor.StopReason.INACTIVE);
      PositionMonitor.start(PositionMonitor.StopReason.PAUSE);

      uriViewer.setPlayPauseButton(false);
      uriViewer.enqueueUri(null);

      onRadioPlayerFinished(player);
    }
  }

  private static void onUriPlayerFinished () {
    onUriPlayerFinished(null);
  }

  private static boolean requestAudioFocus () {
    return requestAudioFocus(false);
  }

  private final static MediaPlayer.OnCompletionListener mediaPlayerCompletionListener =
    new MediaPlayer.OnCompletionListener() {
      @Override
      public void onCompletion (MediaPlayer player) {
        if (RadioParameters.LOG_URI_PLAYER) {
          Log.d(LOG_TAG, "media layer finished");
        }

        onUriPlayerFinished();
      }
    };

  private final static MediaPlayer.OnInfoListener mediaPlayerInfoListener =
    new MediaPlayer.OnInfoListener() {
      private final String getInfoMessage (int info) {
        switch (info) {
          default:
            return null;
        }
      }

      @Override
      public boolean onInfo (MediaPlayer player, int info, int extra) {
        StringBuilder log = new StringBuilder();
        log.append("media player info ");
        log.append(info);
        log.append('.');
        log.append(extra);

        {
          String message = getInfoMessage(info);

          if (message != null) {
            log.append(": ");
            log.append(message);
          }
        }

        Log.w(LOG_TAG, log.toString());
        return false;
      }
    };

  private final static MediaPlayer.OnErrorListener mediaPlayerErrorListener =
    new MediaPlayer.OnErrorListener() {
      private final String getErrorMessage (int error) {
        switch (error) {
          case MediaPlayer.MEDIA_ERROR_SERVER_DIED:
            return "media player died";

          default:
            return null;
        }
      }

      @Override
      public boolean onError (MediaPlayer player, int error, int extra) {
        StringBuilder log = new StringBuilder();
        log.append("media player error ");
        log.append(error);
        log.append('.');
        log.append(extra);

        {
          String message = getErrorMessage(error);

          if (message != null) {
            log.append(": ");
            log.append(message);
          }
        }

        Log.e(LOG_TAG, log.toString());
        return false;
      }
    };

  private final static MediaPlayer.OnPreparedListener mediaPlayerPreparedListener =
    new MediaPlayer.OnPreparedListener() {
      @Override
      public void onPrepared (MediaPlayer player) {
        if (RadioParameters.LOG_URI_PLAYER) {
          Log.d(LOG_TAG, "media layer prepared");
        }

        synchronized (AUDIO_LOCK) {
          uriViewer.setDuration(mediaPlayer.getDuration());
          uriViewer.setPosition(0);
          uriViewer.setPlayPauseButton(true);
        }

        if (RadioParameters.LOG_URI_PLAYER) {
          Log.d(LOG_TAG, "starting media player");
        }

        if (requestAudioFocus()) {
          mediaPlayer.start();
          PositionMonitor.start(PositionMonitor.StopReason.INACTIVE);
        } else {
          onUriPlayerFinished();
        }
      }
    };

  static {
    mediaPlayer.setOnInfoListener(mediaPlayerInfoListener);
    mediaPlayer.setOnErrorListener(mediaPlayerErrorListener);
    mediaPlayer.setOnPreparedListener(mediaPlayerPreparedListener);
    mediaPlayer.setOnCompletionListener(mediaPlayerCompletionListener);
  }

  public static int getPosition () {
    synchronized (AUDIO_LOCK) {
      return mediaPlayer.getCurrentPosition();
    }
  }

  public static void setPosition (int milliseconds) {
    synchronized (AUDIO_LOCK) {
      mediaPlayer.seekTo(milliseconds);
    }
  }

  protected final boolean play (Uri uri, int audioContentType) {
    if (uri == null) return false;

    if (RadioParameters.LOG_URI_PLAYER) {
      Log.d(LOG_TAG, "resetting media player");
    }

    mediaPlayer.reset();
    logPlaying("URI", uri.toString());

    synchronized (AUDIO_LOCK) {
      try {
        if (RadioParameters.LOG_URI_PLAYER) {
          Log.d(LOG_TAG, ("setting media player data source: " + uri.toString()));
        }

        mediaPlayer.setDataSource(getContext(), uri);
      } catch (IOException exception) {
        Log.w(LOG_TAG,
          String.format(
            "media player source error: %s: %s",
            uri.toString(), exception.getMessage()
          )
        );

        return false;
      }

      if (ApiTests.HAVE_AudioAttributes) {
        AudioAttributes attributes = new AudioAttributes.Builder()
          .setUsage(AudioAttributes.USAGE_MEDIA)
          .setContentType(audioContentType)
          .build();

        setAudioAttributes(attributes);
        mediaPlayer.setAudioAttributes(attributes);
      }

      if (RadioParameters.LOG_URI_PLAYER) {
        Log.d(LOG_TAG, "preparing media player");
      }

      onPlayStart();
      mediaPlayer.prepareAsync();
      uriViewer.enqueueUri(uri);
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
        mediaPlayer.stop();
        mediaPlayer.reset();
        onUriPlayerFinished(this);
      }
    } finally {
      super.stop();
    }
  }

  private final void suspendPlayer () {
    mediaPlayer.pause();
    PositionMonitor.stop(PositionMonitor.StopReason.PAUSE);
    uriViewer.setPlayPauseButton(false);
  }

  private final void resumePlayer () {
    mediaPlayer.start();
    PositionMonitor.start(PositionMonitor.StopReason.PAUSE);
    uriViewer.setPlayPauseButton(true);
  }

  @Override
  protected final boolean actionPlayPause () {
    synchronized (AUDIO_LOCK) {
      boolean resume = false;

      if (!mediaPlayer.isPlaying()) {
        if (requestAudioFocus()) {
          resume = true;
        }
      }

      if (resume) {
        resumePlayer();
      } else {
        suspendPlayer();
        abandonAudioFocus();
      }

      return true;
    }
  }

  @Override
  protected final boolean actionSuspend () {
    synchronized (AUDIO_LOCK) {
      if (!mediaPlayer.isPlaying()) return false;
      suspendPlayer();
      return true;
    }
  }

  @Override
  protected final boolean actionResume () {
    synchronized (AUDIO_LOCK) {
      if (mediaPlayer.isPlaying()) return false;
      resumePlayer();
      return true;
    }
  }
}
