package cc.mielke.dave.android.radio;

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
  private TextView fileTitle = null;
  private TextView fileArtist = null;

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
          updateText(fileTitle, title);
          updateText(fileArtist, artist);
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

  private SeekBar fileSeek = null;
  private TextView fileCurrent = null;
  private TextView fileRemaining = null;

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
    fileSeek.setProgress(milliseconds);
    fileCurrent.setText(toTime(milliseconds));
    fileRemaining.setText("-" + toTime(fileSeek.getMax() - milliseconds));
  }

  public final void setDuration (int milliseconds) {
    fileSeek.setMax(milliseconds);
  }

  public final void setOnSeekBarChangeListener (SeekBar.OnSeekBarChangeListener listener) {
    fileSeek.setOnSeekBarChangeListener(listener);
  }

  public FileViewer (MainActivity activity) {
    super(activity);

    fileView = mainActivity.findViewById(R.id.view_file);
    fileTitle = mainActivity.findViewById(R.id.file_title);
    fileArtist = mainActivity.findViewById(R.id.file_artist);

    fileSeek = mainActivity.findViewById(R.id.file_seek);
    fileCurrent = mainActivity.findViewById(R.id.file_current);
    fileRemaining = mainActivity.findViewById(R.id.file_remaining);
    fileSeek.setKeyProgressIncrement(10000);

    dequeueThread = new Thread(fileDequeuer);
    dequeueThread.start();
  }
}
