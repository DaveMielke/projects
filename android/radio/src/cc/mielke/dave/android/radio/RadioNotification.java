package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseNotification;

import android.app.Service;

public class RadioNotification extends BaseNotification {
  public RadioNotification (Service service) {
    super(service);
    setTitle(getService().getString(R.string.state_noProgram));
    show(true);
  }

  @Override
  protected int getSmallIcon () {
    return R.drawable.status_bar_icon;
  }
}
