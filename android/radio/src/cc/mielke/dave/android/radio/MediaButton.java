package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.media.session.MediaSession;
import android.media.session.PlaybackState;

import android.app.PendingIntent;
import android.content.Intent;

import android.content.ComponentName;

public abstract class MediaButton extends AudioComponent {
  private final static String LOG_TAG = MediaButton.class.getName();

  private MediaButton () {
  }

  private static PendingIntent newPendingIntent () {
    Intent intent = new Intent(getContext(), MediaButtonReceiver.class);
    return PendingIntent.getBroadcast(getContext(), 0, intent, 0);
  }

  private static MediaSession newMediaSession () {
    MediaSession session = new MediaSession(getContext(), LOG_TAG);

    session.setCallback(
      new MediaSession.Callback() {
        @Override
        public void onPlay () {
          RadioPlayer.Action.PLAY_PAUSE.perform();
        }

        @Override
        public void onPause () {
          RadioPlayer.Action.PAUSE.perform();
        }

        @Override
        public void onSkipToNext () {
          RadioPlayer.Action.NEXT.perform();
        }

        @Override
        public void onSkipToPrevious () {
          RadioPlayer.Action.PREVIOUS.perform();
        }
      }
    );

    session.setPlaybackState(
      new PlaybackState.Builder()
        .setActions(
          PlaybackState.ACTION_SKIP_TO_NEXT |
          PlaybackState.ACTION_SKIP_TO_PREVIOUS |
          PlaybackState.ACTION_PLAY |
          PlaybackState.ACTION_PAUSE |
          PlaybackState.ACTION_PLAY_PAUSE
        )

        .setState(PlaybackState.STATE_STOPPED, 0, 1f)
        .build()
    );

    session.setFlags(MediaSession.FLAG_HANDLES_MEDIA_BUTTONS);
    session.setMediaButtonReceiver(newPendingIntent());

    session.setActive(true);
    return session;
  }

  private abstract static class Model {
    public abstract boolean isClaimed ();
    public abstract void claim ();
    public abstract void release ();

    protected Model (String name) {
      Log.d(LOG_TAG, ("using model: " + name));
    }
  }

  private static class MediaSessionModel extends Model {
    private MediaSession mediaSession = null;

    @Override
    public boolean isClaimed () {
      return mediaSession != null;
    }

    @Override
    public void claim () {
      mediaSession = newMediaSession();
    }

    @Override
    public void release () {
      mediaSession.release();
      mediaSession = null;
    }

    public MediaSessionModel () {
      super("media session");
    }
  }

  private static class PendingIntentModel extends Model {
    private PendingIntent pendingIntent = null;

    @Override
    public boolean isClaimed () {
      return pendingIntent != null;
    }

    @Override
    public void claim () {
      pendingIntent = newPendingIntent();
      audioManager.registerMediaButtonEventReceiver(pendingIntent);
    }

    @Override
    public void release () {
      audioManager.unregisterMediaButtonEventReceiver(pendingIntent);
      pendingIntent = null;
    }

    public PendingIntentModel () {
      super("pending intent");
    }
  }

  private static class BroadcastReceiverModel extends Model {
    private ComponentName receiverComponent = null;

    @Override
    public boolean isClaimed () {
      return receiverComponent != null;
    }

    @Override
    public void claim () {
      receiverComponent = new ComponentName(getContext(), MediaButtonReceiver.class);
      audioManager.registerMediaButtonEventReceiver(receiverComponent);
    }

    @Override
    public void release () {
      audioManager.unregisterMediaButtonEventReceiver(receiverComponent);
      receiverComponent = null;
    }

    public BroadcastReceiverModel () {
      super("broadcast receiver");
    }
  }

  private final static Model mediaButtonModel =
    ApiTests.haveLollipop? new MediaSessionModel():
    ApiTests.haveJellyBeanMR2? new PendingIntentModel():
    new BroadcastReceiverModel();

  public static void claim () {
    if (mediaButtonModel.isClaimed()) {
      throw new IllegalStateException("already claimed");
    }

    mediaButtonModel.claim();
  }

  public static void release () {
    if (!mediaButtonModel.isClaimed()) {
      throw new IllegalStateException("not claimed");
    }

    mediaButtonModel.release();
  }
}
