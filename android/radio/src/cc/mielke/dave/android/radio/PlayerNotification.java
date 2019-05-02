package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseNotification;

import android.app.Service;

public class PlayerNotification extends BaseNotification {
  public PlayerNotification (Service service) {
    super(service);
  }

  @Override
  protected int getSmallIcon () {
    return R.drawable.ic_launcher;
  }

  @Override
  protected int getLargeIcon () {
    return R.drawable.ic_launcher;
  }
}
