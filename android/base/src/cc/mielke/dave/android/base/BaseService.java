package cc.mielke.dave.android.base;

import android.app.Service;

public abstract class BaseService extends Service {
  @Override
  public void onCreate () {
    super.onCreate();
    BaseApplication.setContext(this);
  }
}
