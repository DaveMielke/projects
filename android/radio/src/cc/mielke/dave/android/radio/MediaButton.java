package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;

import android.util.Log;

import android.content.Intent;
import android.view.KeyEvent;

import android.media.session.MediaSession;
import android.app.PendingIntent;
import android.content.ComponentName;

public abstract class MediaButton extends AudioComponent {
  private final static String LOG_TAG = MediaButton.class.getName();

  private MediaButton () {
  }

  public static void handleIntent (Intent intent) {
    String action = intent.getAction();

    if (action !=  null) {
      if (action.equals(Intent.ACTION_MEDIA_BUTTON)) {
        KeyEvent event = intent.getParcelableExtra(Intent.EXTRA_KEY_EVENT);

        if (event != null) {
          if (event.getAction() == KeyEvent.ACTION_DOWN) {
            int key = event.getKeyCode();

            switch (key) {
              case KeyEvent.KEYCODE_MEDIA_PLAY:
              case KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE:
                RadioPlayer.Action.PLAY_PAUSE.perform();
                break;

              case KeyEvent.KEYCODE_MEDIA_PAUSE:
                RadioPlayer.Action.PAUSE.perform();
                break;

              case KeyEvent.KEYCODE_MEDIA_NEXT:
                RadioPlayer.Action.NEXT.perform();
                break;

              case KeyEvent.KEYCODE_MEDIA_PREVIOUS:
                RadioPlayer.Action.PREVIOUS.perform();
                break;

              default:
                Log.w(LOG_TAG, String.format("unhandled key: %d: %s", key, KeyEvent.keyCodeToString(key)));
                break;
            }
          }
        } else {
          Log.w(LOG_TAG, "key event not specified");
        }
      } else {
        Log.w(LOG_TAG, ("unexpected action: " + action));
      }
    } else {
      Log.w(LOG_TAG, "action not specified");
    }
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
        public boolean onMediaButtonEvent (Intent intent) {
          handleIntent(intent);
          return true;
        }

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

    session.setMediaButtonReceiver(newPendingIntent());
    session.setFlags(MediaSession.FLAG_HANDLES_MEDIA_BUTTONS);

    session.setActive(true);
    return session;
  }

  public static void claim () {
    if (USE_MEDIA_SESSION) {
      mediaSession = newMediaSession();
    } else if (USE_PENDING_INTENT) {
      pendingIntent = newPendingIntent();
      audioManager.registerMediaButtonEventReceiver(pendingIntent);
    } else {
      receiverComponent = new ComponentName(getContext(), MediaButtonReceiver.class);
      audioManager.registerMediaButtonEventReceiver(receiverComponent);
    }
  }

  public static void release () {
    if (USE_MEDIA_SESSION) {
      mediaSession.release();
      mediaSession = null;
    } else if (USE_PENDING_INTENT) {
      audioManager.unregisterMediaButtonEventReceiver(pendingIntent);
      pendingIntent = null;
    } else {
      audioManager.unregisterMediaButtonEventReceiver(receiverComponent);
      receiverComponent = null;
    }
  }
}
