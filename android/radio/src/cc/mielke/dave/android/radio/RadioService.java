package cc.mielke.dave.android.radio;

import android.util.Log;

import android.app.Service;
import android.os.IBinder;
import android.content.Intent;

public class RadioService extends Service {
  private final static String LOG_TAG = RadioService.class.getName();

  private RadioNotification radioNotification = null;

  @Override
  public void onCreate () {
    super.onCreate();
    Log.d(LOG_TAG, "starting");
    radioNotification = new RadioNotification(this);
  }

  @Override
  public void onDestroy () {
    try {
      Log.d(LOG_TAG, "stopping");
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
}
