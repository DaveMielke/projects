package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseNotification;
import cc.mielke.dave.android.base.ApiTests;

import android.app.Notification;
import android.app.Service;

public class RadioNotification extends BaseNotification {
  private int indexPlayPause = -1;
  private Notification.Action actionPlay = null;
  private Notification.Action actionPause = null;

  public RadioNotification (Service service) {
    super(service);

    addAction(
      android.R.drawable.ic_media_previous,
      getString(R.string.action_uriPrevious),
      PreviousActivity.class
    );

    indexPlayPause = addAction(
      android.R.drawable.ic_media_play,
      getString(R.string.action_uriPlay),
      PlayPauseActivity.class
    );

    addAction(
      android.R.drawable.ic_media_next,
      getString(R.string.action_uriNext),
      NextActivity.class
    );

    if (ApiTests.HAVE_Notification_Action) {
      actionPlay = getAction(indexPlayPause);

      actionPause = newAction(
        android.R.drawable.ic_media_pause,
        getString(R.string.action_uriPause),
        PlayPauseActivity.class
      );
    }

    setTitle(getService().getString(R.string.state_noProgram));
    showNotification(true);
  }

  public final boolean setPlayPauseAction (boolean isPlaying) {
    if (ApiTests.HAVE_Notification_Action) {
      Notification.Action action = isPlaying? actionPause: actionPlay;
      return setAction(indexPlayPause, action);
    }

    return false;
  }

  @Override
  protected int getSmallIcon () {
    return R.drawable.status_bar_icon;
  }
}
