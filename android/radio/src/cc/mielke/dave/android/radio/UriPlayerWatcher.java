package cc.mielke.dave.android.radio;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import android.util.Log;

import android.media.MediaMetadataRetriever;
import android.net.Uri;

import android.content.Context;

public class UriPlayerWatcher extends RadioComponent {
  private final static String LOG_TAG = UriPlayerWatcher.class.getName();

  public static interface OnChangeListener {
    public void onMetadataChange (boolean visible, CharSequence title, CharSequence artist);
    public void onPlayPauseChange (Boolean isPlaying);
    public void onDurationChange (int milliseconds);
    public void onPositionChange (int milliseconds);
  }

  private OnChangeListener onChangeListener = null;
  private boolean metadataVisible;
  private CharSequence metadataTitle;
  private CharSequence metadataArtist;
  private Boolean playPause;
  private int seekDuration;
  private int seekPosition;

  private final void onMetadataChange () {
    onChangeListener.onMetadataChange(metadataVisible, metadataTitle, metadataArtist);
  }

  private final void onPlayPauseChange () {
    onChangeListener.onPlayPauseChange(playPause);
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
        metadataVisible = false;
        metadataTitle = null;
        metadataArtist = null;
      } else {
        metadataVisible = true;
        metadataTitle = arguments[0];
        metadataArtist = arguments[1];
      }
    }

    getHandler().post(
      new Runnable() {
        @Override
        public void run () {
          synchronized (UriPlayerWatcher.this) {
            if (onChangeListener != null) onMetadataChange();
            updateNotification(metadataTitle, metadataArtist);
          }
        }
      }
    );
  }

  private final BlockingQueue<String> uriQueue = new LinkedBlockingQueue<>();
  private Thread dequeueThread = null;

  public final void onUriChange (Uri uri) {
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
            try {
              try {
                retriever.setDataSource(context, Uri.parse(uri));
              } catch (IllegalArgumentException exception) {
                updateMetadata();
                continue;
              }

              updateMetadata(
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE),
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
              );
            } finally {
              retriever.release();
            }
          }
        }
      }
    };

  public final void onPlayPauseChange (Boolean isPlaying) {
    synchronized (this) {
      if (isPlaying != null) {
        if (playPause == null) MediaButton.claim();
      } else {
        if (playPause != null) MediaButton.release();
      }

      playPause = isPlaying;
      if (onChangeListener != null) onPlayPauseChange();
      RadioService.setPlayPause(isPlaying);
    }
  }

  public final void onDurationChange (int milliseconds) {
    synchronized (this) {
      seekDuration = milliseconds;
      if (onChangeListener != null) onDurationChange();
    }
  }

  public final void onPositionChange (int milliseconds) {
    synchronized (this) {
      seekPosition = milliseconds;
      if (onChangeListener != null) onPositionChange();
    }
  }

  public UriPlayerWatcher () {
    super();

    updateMetadata();
    onPlayPauseChange(null);
    onDurationChange(0);
    onPositionChange(0);

    dequeueThread = new Thread(uriDequeuer);
    dequeueThread.start();
  }
}
