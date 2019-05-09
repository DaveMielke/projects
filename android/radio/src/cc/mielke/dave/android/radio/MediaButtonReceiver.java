package cc.mielke.dave.android.radio;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class MediaButtonReceiver extends BroadcastReceiver {
  @Override
  public void onReceive (Context context, Intent intent) {
    MediaButton.handleIntent(intent);
  }
}
