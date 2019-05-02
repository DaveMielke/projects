package cc.mielke.dave.android.radio;

import android.util.Log;

import android.app.Service;
import android.os.IBinder;
import android.content.Intent;

public class PlayerService extends Service {
  private final static String LOG_TAG = PlayerService.class.getName();

  private PlayerNotification playerNotification = null;

  @Override
  public void onCreate () {
    super.onCreate();
    Log.d(LOG_TAG, "starting");
    playerNotification = new PlayerNotification(this);
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
    return new Intent(RadioApplication.getContext(), PlayerService.class);
  }

  public static void start () {
    RadioApplication.getContext().startService(makeIntent());
  }
}
