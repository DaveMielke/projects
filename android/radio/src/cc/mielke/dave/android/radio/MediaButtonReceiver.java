package cc.mielke.dave.android.radio;

import android.util.Log;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.view.KeyEvent;

public class MediaButtonReceiver extends BroadcastReceiver {
  private final static String LOG_TAG = MediaButtonReceiver.class.getName();

  @Override
  public void onReceive (Context context, Intent intent) {
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
}
