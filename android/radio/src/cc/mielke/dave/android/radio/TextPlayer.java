package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class TextPlayer extends RadioPlayer {
  private final String LOG_TAG = getClass().getName();

  protected TextPlayer (RadioProgram program) {
    super(program);
  }

  protected final boolean play (String text) {
    logPlaying("text", text);
    return false;
  }
}
