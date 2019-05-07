package cc.mielke.dave.android.radio;

import android.util.Log;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class ActionReceiver extends BroadcastReceiver {
  private final static String LOG_TAG = ActionReceiver.class.getName();

  @Override
  public void onReceive (Context context, Intent intent) {
    String name = intent.getAction();
    RadioPlayer.Action action;

    try {
      action = RadioPlayer.Action.valueOf(name);
    } catch (IllegalArgumentException exception) {
      Log.d(LOG_TAG, ("unsupported action: " + name));
      return;
    }

    action.perform();
  }
}
