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
  private static Thread positionMonitorThread = null;
  private static int positionMonitorStopDepth = 1;
  private static FileViewer fileViewer = null;
  private static RadioPlayer currentPlayer = null;

  private static void logPositionMonitorAction (String action, String reason) {
    Log.d(LOG_TAG,
      String.format(
        "%s position monitor: %s: %d",
        action, reason, positionMonitorStopDepth
      )
    );
  }

  private static void startPositionMonitor (String reason) {
    synchronized (PLAYER_LOCK) {
      if (RadioParameters.LOG_POSITION_MONITOR) {
        logPositionMonitorAction("start", reason);
      }

      if (positionMonitorStopDepth <= 0) {
        throw new IllegalStateException("position monitor stop depth underflow");
      }

      if (--positionMonitorStopDepth == 0) {
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
                      fileViewer.setPosition(mediaPlayer.getCurrentPosition());
                    }
                  }
                );

                if (stop) break;

                try {
                  sleep(RadioParameters.FILE_POSITION_INTERVAL);
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

  private static void stopPositionMonitor (String reason) {
    synchronized (PLAYER_LOCK) {
      if (RadioParameters.LOG_POSITION_MONITOR) {
        logPositionMonitorAction("stop", reason);
      }

      if (positionMonitorStopDepth++ == 0) {
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
        stopPositionMonitor("touch begin");
      }

      @Override
      public void onStopTrackingTouch (SeekBar seekBar) {
        startPositionMonitor("touch end");
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

  private static void onMediaPlayerDone () {
    synchronized (PLAYER_LOCK) {
      stopPositionMonitor("media end");
      mediaPlayer.reset();

      if (fileViewer != null) {
        fileViewer.setPlayPauseButton(false);
        fileViewer.enqueueFile(null);
      }

      if (currentPlayer != null) {
        RadioPlayer player = currentPlayer;
        currentPlayer = null;
        player.onPlayEnd();
      } else {
        Log.w(LOG_TAG, "no current player");
      }
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
        onMediaPlayerDone();
        return true;
      }
    };

  private final static MediaPlayer.OnPreparedListener mediaPlayerPreparedListener =
    new MediaPlayer.OnPreparedListener() {
      @Override
      public void onPrepared (MediaPlayer player) {
        if (fileViewer != null) {
          fileViewer.setDuration(mediaPlayer.getDuration());
          fileViewer.setPosition(0);
          fileViewer.setPlayPauseButton(true);
        }

        mediaPlayer.start();
        startPositionMonitor("media begin");
      }
    };

  private final static MediaPlayer.OnCompletionListener mediaPlayerCompletionListener =
    new MediaPlayer.OnCompletionListener() {
      @Override
      public void onCompletion (MediaPlayer player) {
        onMediaPlayerDone();
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

  public static void playPause () {
    synchronized (PLAYER_LOCK) {
      boolean isPlaying;

      if (mediaPlayer == null) {
        isPlaying = false;
      } else if (mediaPlayer.isPlaying()) {
        mediaPlayer.pause();
        stopPositionMonitor("pause");
        isPlaying = false;
      } else {
        mediaPlayer.start();
        startPositionMonitor("play");
        isPlaying = true;
      }

      if (fileViewer != null) fileViewer.setPlayPauseButton(isPlaying);
    }
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
      if (currentPlayer != null) {
        throw new IllegalStateException("already playing");
      }

      if (ApiTests.haveLollipop) {
        AudioAttributes.Builder builder = new AudioAttributes.Builder();
        builder.setUsage(AudioAttributes.USAGE_MEDIA);
        builder.setContentType(audioContentType);
        mediaPlayer.setAudioAttributes(builder.build());
      }

      try {
        mediaPlayer.setDataSource(getContext(), Uri.fromFile(file));
      } catch (IOException exception) {
        Log.e(LOG_TAG, ("media player source error: " + exception.getMessage()));
        return false;
      }

      if (fileViewer != null) fileViewer.enqueueFile(file);
      currentPlayer = this;
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
          onMediaPlayerDone();
        }
      }
    } finally {
      super.stop();
    }
  }
}
