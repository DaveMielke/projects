package cc.mielke.dave.android.radio;

import android.util.Log;

import cc.mielke.dave.android.base.BaseActivity;
import android.os.Bundle;

public class PreviousActivity extends BaseActivity {
  private final static String LOG_TAG = PreviousActivity.class.getName();

  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    RadioPlayer.Action.PREVIOUS.perform();
    finish();
  }
}
