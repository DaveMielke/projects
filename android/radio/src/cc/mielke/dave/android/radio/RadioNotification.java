package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseNotification;

import android.app.Service;
import android.app.Activity;

public class RadioNotification extends BaseNotification {
  public RadioNotification (Service service) {
    super(service);
    show(true);
  }

  @Override
  protected int getSmallIcon () {
    return R.drawable.status_bar_icon;
  }

  @Override
  protected int getLargeIcon () {
    return R.drawable.radio;
  }

  @Override
  protected Class<? extends Activity> getMainActivityClass () {
    return MainActivity.class;
  }
}
