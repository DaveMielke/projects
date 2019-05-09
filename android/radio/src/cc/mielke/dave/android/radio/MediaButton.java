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

  private final static boolean USE_MEDIA_SESSION = ApiTests.haveLollipop;
  private final static boolean USE_PENDING_INTENT = ApiTests.haveJellyBeanMR2;

  private static MediaSession mediaSession = null;
  private static PendingIntent pendingIntent = null;
  private static ComponentName receiverComponent = null;

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

  public static void claim () {
    if (USE_MEDIA_SESSION) {
      if (mediaSession != null) {
        throw new IllegalStateException("media session already active");
      }

      mediaSession = newMediaSession();
    } else if (USE_PENDING_INTENT) {
      if (pendingIntent != null) {
        throw new IllegalStateException("pending intent already registered");
      }

      pendingIntent = newPendingIntent();
      audioManager.registerMediaButtonEventReceiver(pendingIntent);
    } else {
      if (receiverComponent != null) {
        throw new IllegalStateException("receiver component already registered");
      }

      receiverComponent = new ComponentName(getContext(), MediaButtonReceiver.class);
      audioManager.registerMediaButtonEventReceiver(receiverComponent);
    }
  }

  public static void release () {
    if (USE_MEDIA_SESSION) {
      if (mediaSession == null) {
        throw new IllegalStateException("media session not active");
      }

      mediaSession.release();
      mediaSession = null;
    } else if (USE_PENDING_INTENT) {
      if (pendingIntent == null) {
        throw new IllegalStateException("pending intent not registered");
      }

      audioManager.unregisterMediaButtonEventReceiver(pendingIntent);
      pendingIntent = null;
    } else {
      if (receiverComponent == null) {
        throw new IllegalStateException("receiver component not registered");
      }

      audioManager.unregisterMediaButtonEventReceiver(receiverComponent);
      receiverComponent = null;
    }
  }
}
