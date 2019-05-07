package cc.mielke.dave.android.radio;

import android.util.Log;

import android.app.Service;
import android.os.IBinder;
import android.content.Intent;

public class RadioService extends Service {
  private final static String LOG_TAG = RadioService.class.getName();

  private final static Object SERVICE_LOCK = new Object();
  private static RadioNotification radioNotification = null;

  @Override
  public void onCreate () {
    super.onCreate();
    Log.d(LOG_TAG, "creating");

    synchronized (SERVICE_LOCK) {
      radioNotification = new RadioNotification(this);
    }
  }

  @Override
  public void onDestroy () {
    try {
      Log.d(LOG_TAG, "destroying");

      synchronized (SERVICE_LOCK) {
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
