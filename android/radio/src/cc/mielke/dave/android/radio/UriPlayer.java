package cc.mielke.dave.android.radio;

import java.io.IOException;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.media.MediaPlayer;
import android.media.AudioAttributes;
import android.net.Uri;
import android.widget.SeekBar;

public abstract class UriPlayer extends RadioPlayer {
  private final static String LOG_TAG = UriPlayer.class.getName();

  protected UriPlayer () {
    super();
  }

  private final static Object PLAYER_LOCK = new Object();
  private static MediaPlayer mediaPlayer = null;
  private static UriViewer uriViewer = null;

  private static Thread positionMonitorThread = null;
  private static int positionMonitorStopDepth = 0;

  private static enum PositionMonitorStopReason {
    INACTIVE(true),
    INVISIBLE(true),
    PAUSE(false),
    TOUCH(false),
    ; // end of enumeration

    private boolean currentState = false;

    private final boolean set (boolean state, String action) {
      if (state == currentState) return false;

      if (RadioParameters.LOG_POSITION_MONITOR) {
        if (action != null) {
          Log.d(LOG_TAG,
            String.format(
              "%s position monitor: %s: %d",
              action, name(), positionMonitorStopDepth
            )
          );
        }
      }

      if ((currentState = state)) {
        return positionMonitorStopDepth++ == 0;
      }

      if (positionMonitorStopDepth <= 0) {
        throw new IllegalStateException("stop depth underflow");
      }

      return --positionMonitorStopDepth == 0;
    }

    public final boolean begin () {
      return set(true, "stop");
    }

    public final boolean end () {
      return set(false, "start");
    }

    PositionMonitorStopReason (boolean state) {
      set(state, null);
    }
  }

  private static void startPositionMonitor (PositionMonitorStopReason reason) {
    synchronized (PLAYER_LOCK) {
      if (reason.end()) {
        positionMonitorThread =
          new Thread("position-mnitor") {
            @Override
            public void run () {
              if (RadioParameters.LOG_POSITION_MONITOR) {
                Log.d(LOG_TAG, "position monitor started");
              }

              boolean stop = false;

              while (true) {
                post(
                  new Runnable() {
                    @Override
                    public void run () {
                      synchronized (PLAYER_LOCK) {
                        uriViewer.setPosition(mediaPlayer.getCurrentPosition());
                      }
                    }
                  }
                );

                if (stop) break;

                try {
                  sleep(RadioParameters.POSITION_MONITOR_INTERVAL);
                } catch (InterruptedException exception) {
                  stop = true;
                }
              }

              if (RadioParameters.LOG_POSITION_MONITOR) {
                Log.d(LOG_TAG, "position monitor stopped");
              }
            }
          };

        positionMonitorThread.start();
      }
    }
  }

  private static void stopPositionMonitor (PositionMonitorStopReason reason) {
    synchronized (PLAYER_LOCK) {
      if (reason.begin()) {
        positionMonitorThread.interrupt();
        positionMonitorThread = null;
      }
    }
  }

  private final static SeekBar.OnSeekBarChangeListener positionChangedListener =
    new SeekBar.OnSeekBarChangeListener() {
      @Override
      public void onProgressChanged (SeekBar seekBar, int position, boolean fromUser) {
        if (fromUser) {
          mediaPlayer.seekTo(position);
        }
      }

      @Override
      public void onStartTrackingTouch (SeekBar seekBar) {
        stopPositionMonitor(PositionMonitorStopReason.TOUCH);
      }

      @Override
      public void onStopTrackingTouch (SeekBar seekBar) {
        startPositionMonitor(PositionMonitorStopReason.TOUCH);
      }
    };

  public static UriViewer getViewer () {
    synchronized (PLAYER_LOCK) {
      return uriViewer;
    }
  }

  public static void setViewer (UriViewer viewer) {
    synchronized (PLAYER_LOCK) {
      if (viewer != null) {
        viewer.setOnSeekBarChangeListener(positionChangedListener);
      }

      uriViewer = viewer;
    }
  }

  private static void onUriPlayerFinished (UriPlayer player) {
    synchronized (PLAYER_LOCK) {
      stopPositionMonitor(PositionMonitorStopReason.INACTIVE);
      startPositionMonitor(PositionMonitorStopReason.PAUSE);

      uriViewer.setPlayPauseButton(false);
      uriViewer.enqueueUri(null);

      onRadioPlayerFinished(player);
    }
  }

  private static void onUriPlayerFinished () {
    onUriPlayerFinished(null);
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

        synchronized (PLAYER_LOCK) {
          uriViewer.setDuration(mediaPlayer.getDuration());
          uriViewer.setPosition(0);
          uriViewer.setPlayPauseButton(true);
        }

        if (RadioParameters.LOG_URI_PLAYER) {
          Log.d(LOG_TAG, "starting media player");
        }

        mediaPlayer.start();
        startPositionMonitor(PositionMonitorStopReason.INACTIVE);
      }
    };

  private static void ensureMediaPlayer () {
    synchronized (PLAYER_LOCK) {
      if (mediaPlayer == null) {
        mediaPlayer = new MediaPlayer();

        mediaPlayer.setOnInfoListener(mediaPlayerInfoListener);
        mediaPlayer.setOnErrorListener(mediaPlayerErrorListener);

        mediaPlayer.setOnPreparedListener(mediaPlayerPreparedListener);
        mediaPlayer.setOnCompletionListener(mediaPlayerCompletionListener);
      }

      if (RadioParameters.LOG_URI_PLAYER) {
        Log.d(LOG_TAG, "resetting media player");
      }

      mediaPlayer.reset();
    }
  }

  protected final boolean play (Uri uri, int audioContentType) {
    if (uri == null) return false;

    ensureMediaPlayer();
    logPlaying("URI", uri.toString());

    synchronized (PLAYER_LOCK) {
      if (ApiTests.HAVE_AudioAttributes) {
        AudioAttributes.Builder builder = new AudioAttributes.Builder();
        builder.setUsage(AudioAttributes.USAGE_MEDIA);
        builder.setContentType(audioContentType);

        AudioAttributes attributes = builder.build();
        setAudioAttributes(attributes);
        mediaPlayer.setAudioAttributes(attributes);
      }

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

      synchronized (PLAYER_LOCK) {
        if (mediaPlayer != null) {
          mediaPlayer.stop();
          mediaPlayer.reset();
          onUriPlayerFinished(this);
        }
      }
    } finally {
      super.stop();
    }
  }

  public static void playPause () {
    synchronized (PLAYER_LOCK) {
      boolean isPlaying;

      if (mediaPlayer == null) {
        isPlaying = false;
      } else if (mediaPlayer.isPlaying()) {
        mediaPlayer.pause();
        stopPositionMonitor(PositionMonitorStopReason.PAUSE);
        isPlaying = false;
      } else {
        mediaPlayer.start();
        startPositionMonitor(PositionMonitorStopReason.PAUSE);
        isPlaying = true;
      }

      uriViewer.setPlayPauseButton(isPlaying);
    }
  }

  public static void playNext () {
  }

  public static void playPrevious () {
  }

  public static void setVisible () {
    startPositionMonitor(PositionMonitorStopReason.INVISIBLE);
  }

  public static void setInvisible () {
    stopPositionMonitor(PositionMonitorStopReason.INVISIBLE);
  }
}
