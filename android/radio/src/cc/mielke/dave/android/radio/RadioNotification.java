package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseNotification;

import android.app.Service;

public class RadioNotification extends BaseNotification {
  public RadioNotification (Service service) {
    super(service);
    show(true);
  }

  @Override
  protected int getSmallIcon () {
    return R.drawable.radio;
  }

  @Override
  protected int getLargeIcon () {
    return R.drawable.radio;
  }
}
