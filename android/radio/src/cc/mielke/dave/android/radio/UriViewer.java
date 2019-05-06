package cc.mielke.dave.android.radio;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import android.media.MediaMetadataRetriever;
import android.net.Uri;

import android.content.Context;

public class UriViewer extends RadioComponent {
  public static interface OnChangeListener {
    public void onMetadataChange (boolean visible, CharSequence title, CharSequence artist);
    public void onPlayPauseChange (int label, int image);
    public void onDurationChange (int milliseconds);
    public void onPositionChange (int milliseconds);
  }

  private OnChangeListener onChangeListener = null;

  public final void setOnChangeListener (OnChangeListener listener) {
    synchronized (this) {
      onChangeListener = listener;
    }
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

          synchronized (this) {
            if (onChangeListener != null) {
              onChangeListener.onMetadataChange(visible, title, artist);
            }

            updateNotification(title, artist);
          }
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

  public final void setPlayPauseButton (boolean isPlaying) {
    synchronized (this) {
      if (onChangeListener != null) {
        int label;
        int image;

        if (isPlaying) {
          label = R.string.action_uriPause;
          image = android.R.drawable.ic_media_pause;
        } else {
          label = R.string.action_uriPlay;
          image = android.R.drawable.ic_media_play;
        }

        onChangeListener.onPlayPauseChange(label, image);
      }
    }

    RadioService.setPlayPauseAction(isPlaying);
  }

  public final void setDuration (int milliseconds) {
    synchronized (this) {
      if (onChangeListener != null) {
        onChangeListener.onDurationChange(milliseconds);
      }
    }
  }

  public final void setPosition (int milliseconds) {
    synchronized (this) {
      if (onChangeListener != null) {
        onChangeListener.onPositionChange(milliseconds);
      }
    }
  }

/*
  public final void setOnSeekBarChangeListener (SeekBar.OnSeekBarChangeListener listener) {
    seekBar.setOnSeekBarChangeListener(listener);
  }
*/

  public UriViewer () {
    super();

    dequeueThread = new Thread(uriDequeuer);
    dequeueThread.start();
  }
}
