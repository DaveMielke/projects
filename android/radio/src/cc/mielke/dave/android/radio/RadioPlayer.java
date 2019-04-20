package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class RadioPlayer extends RadioComponent {
  private final static String LOG_TAG = RadioPlayer.class.getName();

  protected RadioPlayer () {
    super();
  }

  protected final void logPlaying (String identifier) {
    Log.i(LOG_TAG, ("playing " + identifier));
  }

  public abstract boolean play ();
}
