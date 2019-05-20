package cc.mielke.dave.android.radio;

import android.util.Log;

import cc.mielke.dave.android.base.BaseService;
import android.os.IBinder;
import android.content.Intent;

public class RadioService extends BaseService {
  private final static String LOG_TAG = RadioService.class.getName();

  private final static Object SERVICE_LOCK = new Object();
  private static RadioNotification radioNotification = null;

  private static CharSequence notificationTitle = null;
  private static CharSequence notificationText = null;
  private static Boolean notificationPlayPause = null;

  public static void updateNotification (CharSequence title, CharSequence text) {
    synchronized (SERVICE_LOCK) {
      notificationTitle = title;
      notificationText = text;

      if (radioNotification != null) {
        radioNotification.setTitle(title);
        radioNotification.setText(text);
        radioNotification.showNotification();
      }
    }
  }

  public static void setPlayPause (Boolean isPlaying) {
    synchronized (SERVICE_LOCK) {
      notificationPlayPause = isPlaying;

      if (radioNotification != null) {
        radioNotification.setPlayPause(isPlaying);
        radioNotification.showNotification();
      }
    }
  }

  @Override
  public void onCreate () {
    super.onCreate();

    synchronized (SERVICE_LOCK) {
      radioNotification = new RadioNotification(this);
      boolean show = false;

      if (notificationTitle != null) {
        radioNotification.setTitle(notificationTitle);
        show = true;
      }

      if (notificationText != null) {
        radioNotification.setText(notificationText);
        show = true;
      }

      if (notificationPlayPause != null) {
        radioNotification.setPlayPause(notificationPlayPause);
        show = true;
      }

      if (show) radioNotification.showNotification();
    }
  }

  @Override
  public void onDestroy () {
    try {
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
}
