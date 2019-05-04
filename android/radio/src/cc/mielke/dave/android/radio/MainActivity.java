package cc.mielke.dave.android.radio;

import android.util.Log;

import cc.mielke.dave.android.base.BaseActivity;
import android.os.Bundle;
import android.content.Intent;

import android.view.View;
import android.widget.Button;

public class MainActivity extends BaseActivity {
  private final static String LOG_TAG = MainActivity.class.getName();

  private ProgramSelector programSelector = null;

  public final void selectProgram (View view) {
    programSelector.selectProgram();
  }

  public final void uriPlayPause (View view) {
    RadioPlayer.performAction(RadioPlayer.Action.PLAY_PAUSE);
  }

  public final void uriNext (View view) {
    RadioPlayer.performAction(RadioPlayer.Action.NEXT);
  }

  public final void uriPrevious (View view) {
    RadioPlayer.performAction(RadioPlayer.Action.PREVIOUS);
  }

  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Log.d(LOG_TAG, "creating");
    setContentView(R.layout.main);

    UriPlayer.setViewer(new UriViewer(this));
    SpeechPlayer.setViewer(new SpeechViewer(this));

    programSelector = new ProgramSelector(this);

    RadioService.start();
  }

  @Override
  protected void onNewIntent (Intent intent) {
    Log.d(LOG_TAG, "new intent");
  }

  @Override
  public void onDestroy () {
    try {
      Log.d(LOG_TAG, "destroying");

      RadioService.stop();
    } finally {
      super.onDestroy();
    }
  }

  @Override
  public void onResume () {
    super.onResume();
    UriPlayer.setVisible();
  }

  @Override
  public void onPause () {
    try {
      UriPlayer.setInvisible();
    } finally {
      super.onPause();
    }
  }
}
