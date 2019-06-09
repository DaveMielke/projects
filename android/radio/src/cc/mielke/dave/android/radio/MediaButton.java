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

  private static interface Model {
    public abstract void claim ();
    public abstract void release ();
  }

  private static class MediaSessionModel implements Model {
    private MediaSession mediaSession = null;

    @Override
    public void claim () {
      if (mediaSession != null) {
        throw new IllegalStateException("media session already active");
      }

      mediaSession = newMediaSession();
    }

    @Override
    public void release () {
      if (mediaSession == null) {
        throw new IllegalStateException("media session not active");
      }

      mediaSession.release();
      mediaSession = null;
    }
  }

  private static class PendingIntentModel implements Model {
    private PendingIntent pendingIntent = null;

    @Override
    public void claim () {
      if (pendingIntent != null) {
        throw new IllegalStateException("pending intent already registered");
      }

      pendingIntent = newPendingIntent();
      audioManager.registerMediaButtonEventReceiver(pendingIntent);
    }

    @Override
    public void release () {
      if (pendingIntent == null) {
        throw new IllegalStateException("pending intent not registered");
      }

      audioManager.unregisterMediaButtonEventReceiver(pendingIntent);
      pendingIntent = null;
    }
  }

  private static class BroadcastReceiverModel implements Model {
    private ComponentName receiverComponent = null;

    @Override
    public void claim () {
      if (receiverComponent != null) {
        throw new IllegalStateException("receiver component already registered");
      }

      receiverComponent = new ComponentName(getContext(), MediaButtonReceiver.class);
      audioManager.registerMediaButtonEventReceiver(receiverComponent);
    }

    @Override
    public void release () {
      if (receiverComponent == null) {
        throw new IllegalStateException("receiver component not registered");
      }

      audioManager.unregisterMediaButtonEventReceiver(receiverComponent);
      receiverComponent = null;
    }
  }

  private final static Model model =
    ApiTests.haveLollipop? new MediaSessionModel():
    ApiTests.haveJellyBeanMR2? new PendingIntentModel():
    new BroadcastReceiverModel();

  public static void claim () {
    model.claim();
  }

  public static void release () {
    model.release();
  }
}
