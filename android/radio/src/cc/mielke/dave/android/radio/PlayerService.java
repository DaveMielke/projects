package cc.mielke.dave.android.radio;

import android.util.Log;

import android.app.Service;
import android.os.IBinder;
import android.content.Intent;

public class PlayerService extends Service {
  private final static String LOG_TAG = PlayerService.class.getName();

  private final static Object NOTIFICATION_LOCK = new Object();
  private static PlayerNotification playerNotification = null;

  @Override
  public void onCreate () {
    super.onCreate();
    Log.d(LOG_TAG, "starting");

    synchronized (NOTIFICATION_LOCK) {
      playerNotification = new PlayerNotification(this);
    }
  }

  @Override
  public void onDestroy () {
    try {
      Log.d(LOG_TAG, "stopping");

      synchronized (NOTIFICATION_LOCK) {
        playerNotification.cancel();
        playerNotification = null;
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
    return new Intent(RadioApplication.getContext(), PlayerService.class);
  }

  public static void start () {
    RadioApplication.getContext().startService(makeIntent());
  }

  public static void stop () {
    RadioApplication.getContext().stopService(makeIntent());
  }

  public static void cancel () {
    synchronized (NOTIFICATION_LOCK) {
      playerNotification.cancel();
    }
  }

  public static void show (CharSequence title, CharSequence text) {
    synchronized (NOTIFICATION_LOCK) {
      if (playerNotification != null) {
        if (title == null) title = "";
        if (text == null) text = "";

        playerNotification.setTitle(title);
        playerNotification.setText(text);
        playerNotification.show(true);
      }
    }
  }

  public static void show (CharSequence title) {
    show(title, null);
  }

  public static void show () {
    show(null);
  }
}
