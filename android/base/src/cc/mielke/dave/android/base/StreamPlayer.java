package cc.mielke.dave.android.base;

import java.io.IOException;

import android.util.Log;
import android.content.Context;

import android.media.MediaPlayer;
import android.media.AudioAttributes;
import android.net.Uri;

public class StreamPlayer {
  private final static String LOG_TAG = StreamPlayer.class.getName();

  private final MediaPlayer mediaPlayer = new MediaPlayer();
  private final Context playerContext;

  protected boolean getLogEvents () {
    return false;
  }

  protected boolean onPlayerStart () {
    return true;
  }

  protected boolean onPlayerInfo (int info, int extra) {
    return false;
  }

  protected boolean onPlayerError (int error, int extra) {
    return false;
  }

  protected void onPlayerFinished () {
  }

  private final void resetPlayer () {
    synchronized (this) {
      if (getLogEvents()) {
        Log.d(LOG_TAG, "resetting media player");
      }

      mediaPlayer.reset();
    }
  }

  private final MediaPlayer.OnCompletionListener mediaPlayerCompletionListener =
    new MediaPlayer.OnCompletionListener() {
      @Override
      public void onCompletion (MediaPlayer player) {
        if (getLogEvents()) {
          Log.d(LOG_TAG, "media player finished");
        }

        onPlayerFinished();
      }
    };

  public static Integer getInfoMessage (int info) {
    switch (info) {
      case MediaPlayer.MEDIA_INFO_AUDIO_NOT_PLAYING:
        return R.string.media_info_no_audio;

      case MediaPlayer.MEDIA_INFO_BAD_INTERLEAVING:
        return R.string.media_info_bad_interleaving;

      case MediaPlayer.MEDIA_INFO_BUFFERING_END:
        return R.string.media_info_buffering_finished;

      case MediaPlayer.MEDIA_INFO_BUFFERING_START:
        return R.string.media_info_buffering_started;

      case MediaPlayer.MEDIA_INFO_METADATA_UPDATE:
        return R.string.media_info_metadata_change;

      case MediaPlayer.MEDIA_INFO_NOT_SEEKABLE:
        return R.string.media_info_not_seekable;

      case MediaPlayer.MEDIA_INFO_STARTED_AS_NEXT:
        return R.string.media_info_next_player_started;

      case MediaPlayer.MEDIA_INFO_SUBTITLE_TIMED_OUT:
        return R.string.media_info_subtitle_timeout;

      case MediaPlayer.MEDIA_INFO_UNKNOWN:
        return R.string.media_info_unspecified;

      case MediaPlayer.MEDIA_INFO_UNSUPPORTED_SUBTITLE:
        return R.string.media_info_subtitle_unsupported;

      case MediaPlayer.MEDIA_INFO_VIDEO_NOT_PLAYING:
        return R.string.media_info_no_video;

      case MediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START:
        return R.string.media_info_video_started;

      case MediaPlayer.MEDIA_INFO_VIDEO_TRACK_LAGGING:
        return R.string.media_info_video_lagging;

      default:
        return null;
    }
  }

  private final MediaPlayer.OnInfoListener mediaPlayerInfoListener =
    new MediaPlayer.OnInfoListener() {
      @Override
      public boolean onInfo (MediaPlayer player, int info, int extra) {
        StringBuilder log = new StringBuilder();
        log.append("media player info ");
        log.append(info);
        log.append('.');
        log.append(extra);

        {
          Integer message = getInfoMessage(info);

          if (message != null) {
            log.append(": ");
            log.append(playerContext.getResources().getString(message));
          }
        }

        Log.d(LOG_TAG, log.toString());
        return onPlayerInfo(info, extra);
      }
    };

  public static Integer getErrorMessage (int error) {
    switch (error) {
      case MediaPlayer.MEDIA_ERROR_IO:
        return R.string.media_error_input_output;

      case MediaPlayer.MEDIA_ERROR_MALFORMED:
        return R.string.media_error_bad_stream;

      case MediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK:
        return R.string.media_error_not_progressive;

      case MediaPlayer.MEDIA_ERROR_SERVER_DIED:
        return R.string.media_error_server_died;

      case MediaPlayer.MEDIA_ERROR_TIMED_OUT:
        return R.string.media_error_operation_timeout;

      case MediaPlayer.MEDIA_ERROR_UNKNOWN:
        return R.string.media_error_unknown;

      case MediaPlayer.MEDIA_ERROR_UNSUPPORTED:
        return R.string.media_error_unsupported_feature;

      default:
        return null;
    }
  }

  private final MediaPlayer.OnErrorListener mediaPlayerErrorListener =
    new MediaPlayer.OnErrorListener() {
      @Override
      public boolean onError (MediaPlayer player, int error, int extra) {
        StringBuilder log = new StringBuilder();
        log.append("media player error ");
        log.append(error);
        log.append('.');
        log.append(extra);

        {
          Integer message = getErrorMessage(error);

          if (message != null) {
            log.append(": ");
            log.append(playerContext.getResources().getString(message));
          }
        }

        Log.e(LOG_TAG, log.toString());
        return onPlayerError(error, extra);
      }
    };

  private final MediaPlayer.OnPreparedListener mediaPlayerPreparedListener =
    new MediaPlayer.OnPreparedListener() {
      @Override
      public void onPrepared (MediaPlayer player) {
        if (getLogEvents()) {
          Log.d(LOG_TAG, "media player prepared");
        }

        if (onPlayerStart()) {
          if (getLogEvents()) {
            Log.d(LOG_TAG, "starting media player");
          }

          mediaPlayer.start();
        }
      }
    };

  public int getDuration () {
    synchronized (this) {
      return mediaPlayer.getDuration();
    }
  }

  public int getPosition () {
    synchronized (this) {
      return mediaPlayer.getCurrentPosition();
    }
  }

  public void setPosition (int milliseconds) {
    synchronized (this) {
      mediaPlayer.seekTo(milliseconds);
    }
  }

  public final boolean setSource (Uri uri) {
    synchronized (this) {
      resetPlayer();

      try {
        if (getLogEvents()) {
          Log.d(LOG_TAG, ("setting media player data source: " + uri.toString()));
        }

        mediaPlayer.setDataSource(playerContext, uri);
        return true;
      } catch (IOException exception) {
        Log.w(LOG_TAG,
          String.format(
            "media player source error: %s: %s",
            uri.toString(), exception.getMessage()
          )
        );
      }

      return false;
    }
  }

  public final void setAudioAttributes (AudioAttributes attributes) {
    synchronized (this) {
      mediaPlayer.setAudioAttributes(attributes);
    }
  }

  public final void start () {
    synchronized (this) {
      if (getLogEvents()) {
        Log.d(LOG_TAG, "preparing media player");
      }

      mediaPlayer.prepareAsync();
    }
  }

  public final void stop () {
    synchronized (this) {
      mediaPlayer.stop();
      resetPlayer();
    }
  }

  public final boolean isPlaying () {
    synchronized (this) {
      return mediaPlayer.isPlaying();
    }
  }

  public final void suspend () {
    synchronized (this) {
      mediaPlayer.pause();
    }
  }

  public final void resume () {
    synchronized (this) {
      mediaPlayer.start();
    }
  }

  public StreamPlayer (Context context) {
    playerContext = context;

    mediaPlayer.setOnInfoListener(mediaPlayerInfoListener);
    mediaPlayer.setOnErrorListener(mediaPlayerErrorListener);
    mediaPlayer.setOnPreparedListener(mediaPlayerPreparedListener);
    mediaPlayer.setOnCompletionListener(mediaPlayerCompletionListener);
  }
}
