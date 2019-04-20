package cc.mielke.dave.android.radio;

import android.content.Context;

public class RadioComponent {
  protected RadioComponent () {
    super();
  }

  protected static Context getContext () {
    return RadioApplication.getContext();
  }
}
