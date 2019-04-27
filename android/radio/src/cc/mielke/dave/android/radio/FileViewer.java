package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import java.io.File;
import android.media.MediaMetadataRetriever;

import android.os.Handler;

import android.view.View;
import android.widget.TextView;
import android.widget.SeekBar;

public class FileViewer extends ActivityComponent {
  private final Handler updateHandler = getHandler();

  private View fileView = null;
  private TextView metadataTitle = null;
  private TextView metadataArtist = null;

  private final void updateText (TextView view, String text) {
    if (text == null) text = "";
    view.setText(text);
  }

  private final void updateMetadata (final String... arguments) {
    Runnable updater =
      new Runnable() {
        @Override
        public void run () {
          boolean visible;
          String title;
          String artist;

          if (arguments.length == 0) {
            visible = false;
            title = null;
            artist = null;
          } else {
            visible = true;
            title = arguments[0];
            artist = arguments[1];
          }

          setVisible(fileView, visible);
          updateText(metadataTitle, title);
          updateText(metadataArtist, artist);
        }
      };

    updateHandler.post(updater);
  }

  private final BlockingQueue<String> fileQueue = new LinkedBlockingQueue<>();
  private Thread dequeueThread = null;

  public final void enqueueFile (File file) {
    fileQueue.offer((file != null)? file.getAbsolutePath(): "");
  }

  public final String dequeueFile () {
    while (true) {
      try {
        return fileQueue.take();
      } catch (InterruptedException exception) {
      }
    }
  }

  private final Runnable fileDequeuer =
    new Runnable() {
      @Override
      public void run () {
        while (true) {
          String path = dequeueFile();

          if (path.isEmpty()) {
            updateMetadata();
          } else {
            MediaMetadataRetriever retriever = new MediaMetadataRetriever();
            retriever.setDataSource(path);

            updateMetadata(
              retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE),
              retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
            );

            retriever.release();
          }
        }
      }
    };

  private SeekBar seekBar = null;
  private TextView seekCurrent = null;
  private TextView seekRemaining = null;

  public final void setDuration (int milliseconds) {
    seekBar.setMax(milliseconds);
  }

  private final String toTime (int milliseconds) {
    StringBuilder time = new StringBuilder();

    int seconds = (milliseconds + 499) / 1000;
    int minutes = seconds / 60;
    seconds %= 60;

    int hours = minutes / 60;
    minutes %= 60;

    if (hours > 0) {
      time.append(String.format("%d:%02d", hours, minutes));
    } else {
      time.append(String.format("%d", minutes));
    }

    time.append(String.format(":%02d", seconds));
    return time.toString();
  }

  public final void setPosition (int milliseconds) {
    if (ApiTests.haveNougat) {
      seekBar.setProgress(milliseconds, true);
    } else {
      seekBar.setProgress(milliseconds);
    }

    seekCurrent.setText(toTime(milliseconds));
    seekRemaining.setText("-" + toTime(seekBar.getMax() - milliseconds));
  }

  public final void setOnSeekBarChangeListener (SeekBar.OnSeekBarChangeListener listener) {
    seekBar.setOnSeekBarChangeListener(listener);
  }

  public FileViewer (MainActivity activity) {
    super(activity);
    fileView = mainActivity.findViewById(R.id.view_file);

    metadataTitle = mainActivity.findViewById(R.id.file_metadata_title);
    metadataArtist = mainActivity.findViewById(R.id.file_metadata_artist);

    seekBar = mainActivity.findViewById(R.id.file_seek_bar);
    seekCurrent = mainActivity.findViewById(R.id.file_seek_current);
    seekRemaining = mainActivity.findViewById(R.id.file_seek_remaining);
    seekBar.setKeyProgressIncrement(10000);

    dequeueThread = new Thread(fileDequeuer);
    dequeueThread.start();
  }
}
