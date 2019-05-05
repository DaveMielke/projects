package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;
import static cc.mielke.dave.android.base.TimeConstants.*;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import android.media.MediaMetadataRetriever;
import android.net.Uri;

import android.content.Context;
import android.view.View;
import android.widget.TextView;
import android.widget.Button;
import android.widget.SeekBar;

public class UriViewer extends ActivityComponent {
  private View uriView = null;
  private TextView metadataTitle = null;
  private TextView metadataArtist = null;

  private final void updateText (TextView view, String text) {
    if (text == null) text = "";
    view.setText(text);
    setVisible(view, (text.length() > 0));
  }

  private final void updateMetadata (final String... arguments) {
    getHandler().post(
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

          updateNotification(title, artist);
          setVisible(uriView, visible);
          updateText(metadataTitle, title);
          updateText(metadataArtist, artist);
        }
      }
    );
  }

  private final BlockingQueue<String> uriQueue = new LinkedBlockingQueue<>();
  private Thread dequeueThread = null;

  public final void enqueueUri (Uri uri) {
    uriQueue.offer((uri != null)? uri.toString(): "");
  }

  public final String dequeueUri () {
    while (true) {
      try {
        return uriQueue.take();
      } catch (InterruptedException exception) {
      }
    }
  }

  private final Runnable uriDequeuer =
    new Runnable() {
      @Override
      public void run () {
        Context context = getContext();

        while (true) {
          String uri = dequeueUri();

          if (uri.isEmpty()) {
            updateMetadata();
          } else {
            MediaMetadataRetriever retriever = new MediaMetadataRetriever();
            retriever.setDataSource(context, Uri.parse(uri));

            updateMetadata(
              retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE),
              retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
            );

            retriever.release();
          }
        }
      }
    };

  private Button playPauseButton = null;

  public final void setPlayPauseButton (boolean isPlaying) {
    int label;
    int image;

    if (isPlaying) {
      label = R.string.action_uriPause;
      image = android.R.drawable.ic_media_pause;
    } else {
      label = R.string.action_uriPlay;
      image = android.R.drawable.ic_media_play;
    }

    playPauseButton.setContentDescription(getString(label));
    playPauseButton.setBackgroundResource(image);
  }

  private SeekBar seekBar = null;
  private TextView seekCurrent = null;
  private TextView seekRemaining = null;

  public final void setDuration (int milliseconds) {
    seekBar.setMax(milliseconds);
  }

  private final String toTime (long milliseconds) {
    StringBuilder time = new StringBuilder();

    long seconds = (milliseconds + (SECOND.HALF - 1)) / SECOND.ONE;
    long minutes = seconds / SECONDS_PER_MINUTE;
    seconds %= SECONDS_PER_MINUTE;

    long hours = minutes / MINUTES_PER_HOUR;
    minutes %= MINUTES_PER_HOUR;

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

  public UriViewer (MainActivity activity) {
    super(activity);
    uriView = mainActivity.findViewById(R.id.view_uri);

    metadataTitle = mainActivity.findViewById(R.id.uri_metadata_title);
    metadataArtist = mainActivity.findViewById(R.id.uri_metadata_artist);

    playPauseButton = mainActivity.findViewById(R.id.button_uriPlayPause);

    seekBar = mainActivity.findViewById(R.id.uri_seek_bar);
    seekCurrent = mainActivity.findViewById(R.id.uri_seek_current);
    seekRemaining = mainActivity.findViewById(R.id.uri_seek_remaining);
    seekBar.setKeyProgressIncrement(10000);

    dequeueThread = new Thread(uriDequeuer);
    dequeueThread.start();
  }
}
