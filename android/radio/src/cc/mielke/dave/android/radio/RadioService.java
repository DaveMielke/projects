package cc.mielke.dave.android.radio;

import android.util.Log;

import android.app.Service;
import android.os.IBinder;
import android.content.Intent;

import cc.mielke.dave.android.base.ApiTests;
import android.media.session.MediaSession;
import android.app.PendingIntent;
import android.content.ComponentName;

public class RadioService extends Service {
  private final static String LOG_TAG = RadioService.class.getName();

  private final static boolean HAVE_MediaSession = ApiTests.haveLollipop;
  private final static boolean USE_MediaButton_PendingIntent = ApiTests.haveJellyBeanMR2;

  private MediaSession mediaSession = null;
  private PendingIntent mediaButtonPendingIntent = null;
  private ComponentName mediaButtonComponent = null;

  private final PendingIntent newMediaButtonPendingIntent () {
    Intent intent = new Intent(this, MediaButtonReceiver.class);
    return PendingIntent.getBroadcast(this, 0, intent, 0);
  }

  private final MediaSession newMediaSession () {
    MediaSession session = new MediaSession(this, LOG_TAG);

    session.setCallback(
      new MediaSession.Callback() {
        @Override
        public boolean onMediaButtonEvent (Intent intent) {
          MediaButtonReceiver.handleMediaButtonIntent(intent);
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

    session.setMediaButtonReceiver(newMediaButtonPendingIntent());
    session.setFlags(MediaSession.FLAG_HANDLES_MEDIA_BUTTONS);

    session.setActive(true);
    return session;
  }

  private final void enableMediaButtons () {
    if (HAVE_MediaSession) {
      mediaSession = newMediaSession();
    } else if (USE_MediaButton_PendingIntent) {
      mediaButtonPendingIntent = newMediaButtonPendingIntent();
      AudioComponent.audioManager.registerMediaButtonEventReceiver(mediaButtonPendingIntent);
    } else {
      mediaButtonComponent = new ComponentName(this, MediaButtonReceiver.class);
      AudioComponent.audioManager.registerMediaButtonEventReceiver(mediaButtonComponent);
    }
  }

  private final void disableMediaButtons () {
    if (HAVE_MediaSession) {
      mediaSession.release();
      mediaSession = null;
    } else if (USE_MediaButton_PendingIntent) {
      AudioComponent.audioManager.unregisterMediaButtonEventReceiver(mediaButtonPendingIntent);
      mediaButtonPendingIntent = null;
    } else {
      AudioComponent.audioManager.unregisterMediaButtonEventReceiver(mediaButtonComponent);
      mediaButtonComponent = null;
    }
  }

  private final static Object SERVICE_LOCK = new Object();
  private static RadioNotification radioNotification = null;

  @Override
  public void onCreate () {
    super.onCreate();

    synchronized (SERVICE_LOCK) {
      radioNotification = new RadioNotification(this);
      enableMediaButtons();
    }
  }

  @Override
  public void onDestroy () {
    try {
      synchronized (SERVICE_LOCK) {
        disableMediaButtons();
        radioNotification = null;
      }
    } finally {
      super.onDestroy();
    }
  }

  @Override
  public IBinder onBind (Intent intent) {
    return null;
  }

  @Override
  public int onStartCommand (Intent intent, int flags, int identifier) {
    return START_STICKY;
  }

  public static Intent makeIntent () {
    return new Intent(RadioApplication.getContext(), RadioService.class);
  }

  public static void start () {
    RadioApplication.getContext().startService(makeIntent());
  }

  public static void stop () {
    RadioApplication.getContext().stopService(makeIntent());
  }

  public static void updateNotification (CharSequence title, CharSequence text) {
    synchronized (SERVICE_LOCK) {
      if (radioNotification != null) {
        radioNotification.setTitle(title);
        radioNotification.setText(text);
        radioNotification.showNotification();
      }
    }
  }

  public static void setPlayPause (Boolean isPlaying) {
    synchronized (SERVICE_LOCK) {
      if (radioNotification != null) {
        radioNotification.setPlayPause(isPlaying);
        radioNotification.showNotification();
      }
    }
  }
}
