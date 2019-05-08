package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseNotification;
import android.app.Notification;
import android.app.Service;

import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;

public class RadioNotification extends BaseNotification {
  private final PendingIntent newPendingIntent (RadioPlayer.Action action) {
    Intent intent = newIntent(ActionReceiver.class);
    intent.setAction(action.name());
    return newPendingBroadcastIntent(intent);
  }

  private int indexPlayPause = -1;
  private Notification.Action actionPlay = null;
  private Notification.Action actionPause = null;

  public RadioNotification (Service service) {
    super(service);

    setActivity(MainActivity.class);

    addAction(
      android.R.drawable.ic_media_previous,
      getString(R.string.action_uriPrevious),
      newPendingIntent(RadioPlayer.Action.PREVIOUS)
    );

    indexPlayPause = addAction(
      android.R.drawable.ic_media_play,
      getString(R.string.action_uriPlay),
      newPendingIntent(RadioPlayer.Action.PLAY_PAUSE)
    );

    addAction(
      android.R.drawable.ic_media_next,
      getString(R.string.action_uriNext),
      newPendingIntent(RadioPlayer.Action.NEXT)
    );

    if (USE_ACTION_OBJECTS) {
      actionPlay = getAction(indexPlayPause);

      actionPause = newAction(
        android.R.drawable.ic_media_pause,
        getString(R.string.action_uriPause),
        newPendingIntent(RadioPlayer.Action.PLAY_PAUSE)
      );

      if (CAN_CHANGE_ACTIONS) {
        removeActions();
      }
    }

    showNotification(true);
  }

  public final void setPlayPause (Boolean isPlaying) {
    if (CAN_CHANGE_ACTIONS) {
      if (isPlaying == null) {
        removeActions();
      } else {
        Notification.Action action = isPlaying? actionPause: actionPlay;
        setAction(indexPlayPause, action);
      }
    } else {
      String text;

      if (isPlaying == null) {
        text = "";
      } else {
        int state = isPlaying? R.string.state_playing: R.string.state_paused;
        text = getString(state);
      }

      setSubText(text);
    }
  }

  @Override
  protected int getSmallIcon () {
    return R.drawable.status_bar_icon;
  }
}
