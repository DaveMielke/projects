package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseNotification;

import android.app.Service;

public class RadioNotification extends BaseNotification {
  public RadioNotification (Service service) {
    super(service);

    addAction(
      android.R.drawable.ic_media_previous,
      getString(R.string.action_uriPrevious),
      PreviousActivity.class
    );

    addAction(
      android.R.drawable.ic_media_play,
      getString(R.string.action_uriPlay),
      PlayPauseActivity.class
    );

    addAction(
      android.R.drawable.ic_media_next,
      getString(R.string.action_uriNext),
      NextActivity.class
    );

    setTitle(getService().getString(R.string.state_noProgram));
    show(true);
  }

  @Override
  protected int getSmallIcon () {
    return R.drawable.status_bar_icon;
  }
}
