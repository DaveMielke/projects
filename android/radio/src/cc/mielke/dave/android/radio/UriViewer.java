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
  private boolean uriVisible = false;
  private CharSequence metadataTitle = null;
  private CharSequence metadataArtist = null;
  private int playPauseLabel = R.string.action_uriPlay;
  private int playPauseImage = android.R.drawable.ic_media_play;
  private int seekDuration = 0;
  private int seekPosition = 0;

  private final void onMetadataChange () {
    onChangeListener.onMetadataChange(uriVisible, metadataTitle, metadataArtist);
  }

  private final void onPlayPauseChange () {
    onChangeListener.onPlayPauseChange(playPauseLabel, playPauseImage);
  }

  private final void onDurationChange () {
    onChangeListener.onDurationChange(seekDuration);
  }

  private final void onPositionChange () {
    onChangeListener.onPositionChange(seekPosition);
  }

  public final void setOnChangeListener (OnChangeListener listener) {
    synchronized (this) {
      onChangeListener = listener;

      if (onChangeListener != null) {
        onMetadataChange();
        onPlayPauseChange();
        onDurationChange();
        onPositionChange();
      }
    }
  }

  private final void updateMetadata (String... arguments) {
    synchronized (this) {
      if (arguments.length == 0) {
        uriVisible = false;
        metadataTitle = null;
        metadataArtist = null;
      } else {
        uriVisible = true;
        metadataTitle = arguments[0];
        metadataArtist = arguments[1];
      }
    }

    getHandler().post(
      new Runnable() {
        @Override
        public void run () {
          synchronized (this) {
            if (onChangeListener != null) onMetadataChange();
            updateNotification(metadataTitle, metadataArtist);
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
      if (isPlaying) {
        playPauseLabel = R.string.action_uriPause;
        playPauseImage = android.R.drawable.ic_media_pause;
      } else {
        playPauseLabel = R.string.action_uriPlay;
        playPauseImage = android.R.drawable.ic_media_play;
      }

      if (onChangeListener != null) onPlayPauseChange();
      RadioService.setPlayPauseAction(isPlaying);
    }
  }

  public final void setDuration (int milliseconds) {
    synchronized (this) {
      seekDuration = milliseconds;
      if (onChangeListener != null) onDurationChange();
    }
  }

  public final void setPosition (int milliseconds) {
    synchronized (this) {
      seekPosition = milliseconds;
      if (onChangeListener != null) onPositionChange();
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
