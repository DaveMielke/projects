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

  protected FilePlayer (RadioProgram program) {
    super(program);
  }

  private final static Object PLAYER_LOCK = new Object();
  private static MediaPlayer mediaPlayer = null;
  private static Thread positionMonitor = null;
  private static FileViewer fileViewer = null;
  private static RadioPlayer currentPlayer = null;

  private static void startPositionMonitor () {
    synchronized (PLAYER_LOCK) {
      if (fileViewer != null) {
        if (positionMonitor == null) {
          positionMonitor =
            new Thread("file-player-position-mnitor") {
              @Override
              public void run () {
                Log.d(LOG_TAG, "position monitor started");

                while (true) {
                  post(
                    new Runnable() {
                      @Override
                      public void run () {
                        fileViewer.setPosition(mediaPlayer.getCurrentPosition());
                      }
                    }
                  );

                  try {
                    sleep(1000);
                  } catch (InterruptedException exception) {
                    break;
                  }
                }

                Log.d(LOG_TAG, "position monitor stopped");
              }
            };

          positionMonitor.start();
        }
      }
    }
  }

  private static void stopPositionMonitor () {
    synchronized (PLAYER_LOCK) {
      if (positionMonitor != null) {
        positionMonitor.interrupt();
        positionMonitor = null;
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
        stopPositionMonitor();
      }

      @Override
      public void onStopTrackingTouch (SeekBar seekBar) {
        startPositionMonitor();
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
      stopPositionMonitor();
      if (fileViewer != null) fileViewer.enqueueFile(null);
      mediaPlayer.reset();

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
        }

        mediaPlayer.start();
        startPositionMonitor();
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
