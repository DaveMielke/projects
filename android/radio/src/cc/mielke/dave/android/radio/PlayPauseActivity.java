package cc.mielke.dave.android.radio;

import android.util.Log;

import cc.mielke.dave.android.base.BaseActivity;
import android.os.Bundle;

public class PlayPauseActivity extends BaseActivity {
  private final static String LOG_TAG = PlayPauseActivity.class.getName();

  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    RadioPlayer.Action.PLAY_PAUSE.perform();
    finish();
  }
}
