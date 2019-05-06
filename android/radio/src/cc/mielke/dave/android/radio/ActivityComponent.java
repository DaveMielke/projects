package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseActivity;

public abstract class ActivityComponent extends RadioComponent {
  protected final MainActivity mainActivity;

  protected ActivityComponent (MainActivity activity) {
    super();
    mainActivity = activity;
  }
}
