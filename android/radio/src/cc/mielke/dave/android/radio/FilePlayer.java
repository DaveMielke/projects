package cc.mielke.dave.android.radio;

import java.io.File;
import java.io.IOException;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.media.MediaPlayer;
import android.media.AudioAttributes;
import android.net.Uri;
import android.widget.SeekBar;

public abstract class FilePlayer extends RadioPlayer {
  private final static String LOG_TAG = FilePlayer.class.getName();

  protected FilePlayer () {
    super();
  }

  private final static Object PLAYER_LOCK = new Object();
  private static MediaPlayer mediaPlayer = null;
  private static FileViewer fileViewer = null;

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
          new Thread("file-player-position-mnitor") {
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
                        fileViewer.setPosition(mediaPlayer.getCurrentPosition());
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

  public static FileViewer getViewer () {
    synchronized (PLAYER_LOCK) {
      return fileViewer;
    }
  }

  public static void setViewer (FileViewer viewer) {
    synchronized (PLAYER_LOCK) {
      if (viewer != null) {
        viewer.setOnSeekBarChangeListener(positionChangedListener);
      }

      fileViewer = viewer;
    }
  }

  private static void onFilePlayerFinished () {
    synchronized (PLAYER_LOCK) {
      stopPositionMonitor(PositionMonitorStopReason.INACTIVE);
      startPositionMonitor(PositionMonitorStopReason.PAUSE);

      fileViewer.setPlayPauseButton(false);
      fileViewer.enqueueFile(null);

      mediaPlayer.reset();
      onRadioPlayerFinished();
    }
  }

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
        onFilePlayerFinished();
        return true;
      }
    };

  private final static MediaPlayer.OnPreparedListener mediaPlayerPreparedListener =
    new MediaPlayer.OnPreparedListener() {
      @Override
      public void onPrepared (MediaPlayer player) {
        if (RadioParameters.LOG_FILE_PLAYER) {
          Log.d(LOG_TAG, "media layer prepared");
        }

        synchronized (PLAYER_LOCK) {
          fileViewer.setDuration(mediaPlayer.getDuration());
          fileViewer.setPosition(0);
          fileViewer.setPlayPauseButton(true);
        }

        mediaPlayer.start();
        startPositionMonitor(PositionMonitorStopReason.INACTIVE);
      }
    };

  private final static MediaPlayer.OnCompletionListener mediaPlayerCompletionListener =
    new MediaPlayer.OnCompletionListener() {
      @Override
      public void onCompletion (MediaPlayer player) {
        if (RadioParameters.LOG_FILE_PLAYER) {
          Log.d(LOG_TAG, "media layer finished");
        }

        onFilePlayerFinished();
      }
    };

  private static void ensureMediaPlayer () {
    synchronized (PLAYER_LOCK) {
      if (mediaPlayer == null) {
        mediaPlayer = new MediaPlayer();

        mediaPlayer.setOnErrorListener(mediaPlayerErrorListener);
        mediaPlayer.setOnPreparedListener(mediaPlayerPreparedListener);
        mediaPlayer.setOnCompletionListener(mediaPlayerCompletionListener);
      }
    }
  }

  public static void setVisible () {
    startPositionMonitor(PositionMonitorStopReason.INVISIBLE);
  }

  public static void setInvisible () {
    stopPositionMonitor(PositionMonitorStopReason.INVISIBLE);
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

      fileViewer.setPlayPauseButton(isPlaying);
    }
  }

  public static void playNext () {
  }

  public static void playPrevious () {
  }

  protected final boolean play (File file, int audioContentType) {
    if (file == null) return false;

    if (!file.isFile()) {
      Log.w(LOG_TAG, ("media file not found: " + file.getAbsolutePath()));
      return false;
    }

    ensureMediaPlayer();
    logPlaying("file", file.getAbsolutePath());

    synchronized (PLAYER_LOCK) {
      if (ApiTests.haveLollipop) {
        AudioAttributes.Builder builder = new AudioAttributes.Builder();
        builder.setUsage(AudioAttributes.USAGE_MEDIA);
        builder.setContentType(audioContentType);
        mediaPlayer.setAudioAttributes(builder.build());
      }

      try {
        mediaPlayer.setDataSource(getContext(), Uri.fromFile(file));
      } catch (IOException exception) {
        Log.w(LOG_TAG, ("media player source error: " + exception.getMessage()));
        return false;
      }

      fileViewer.enqueueFile(file);
      mediaPlayer.prepareAsync();
      return true;
    }
  }

  @Override
  public void stop () {
    try {
      synchronized (PLAYER_LOCK) {
        if (mediaPlayer != null) {
          mediaPlayer.stop();
          onFilePlayerFinished();
        }
      }
    } finally {
      super.stop();
    }
  }
}
