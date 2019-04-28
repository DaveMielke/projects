package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseActivity;

import android.view.View;

public abstract class ActivityComponent extends RadioComponent {
  protected final MainActivity mainActivity;

  protected ActivityComponent (MainActivity activity) {
    super();
    mainActivity = activity;
  }

  public final void setVisible (View view, boolean yes) {
    view.setVisibility(yes? View.VISIBLE: View.GONE);
  }
}
