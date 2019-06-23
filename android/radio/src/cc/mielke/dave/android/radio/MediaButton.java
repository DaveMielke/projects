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
    private final MediaSession mediaSession = newMediaSession();

    @Override
    public boolean isClaimed () {
      return mediaSession.isActive();
    }

    @Override
    public void claim () {
      mediaSession.setActive(true);
    }

    @Override
    public void release () {
      mediaSession.setActive(false);
    }

    public MediaSessionModel () {
      super("media session");
    }
  }

  private static class PendingIntentModel extends Model {
    private final PendingIntent pendingIntent = newPendingIntent();
    private boolean isRegistered = false;

    @Override
    public boolean isClaimed () {
      return isRegistered;
    }

    @Override
    public void claim () {
      audioManager.registerMediaButtonEventReceiver(pendingIntent);
      isRegistered = true;
    }

    @Override
    public void release () {
      audioManager.unregisterMediaButtonEventReceiver(pendingIntent);
      isRegistered = false;
    }

    public PendingIntentModel () {
      super("pending intent");
    }
  }

  private static class BroadcastReceiverModel extends Model {
    private final ComponentName receiverComponent = new ComponentName(getContext(), MediaButtonReceiver.class);
    private boolean isRegistered = false;

    @Override
    public boolean isClaimed () {
      return isRegistered;
    }

    @Override
    public void claim () {
      audioManager.registerMediaButtonEventReceiver(receiverComponent);
      isRegistered = true;
    }

    @Override
    public void release () {
      audioManager.unregisterMediaButtonEventReceiver(receiverComponent);
      isRegistered = false;
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
