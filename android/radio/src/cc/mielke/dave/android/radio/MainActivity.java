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
    UriPlayer.playPause();
  }

  public final void uriNext (View view) {
    UriPlayer.playNext();
  }

  public final void uriPrevious (View view) {
    UriPlayer.playPrevious();
  }

  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Log.d(LOG_TAG, "create");
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
      Log.d(LOG_TAG, "destroy");

      RadioService.stop();
    } finally {
      super.onDestroy();
    }
  }

  @Override
  public void onStart () {
    super.onStart();
    Log.d(LOG_TAG, "start");
  }

  @Override
  public void onStop () {
    try {
      Log.d(LOG_TAG, "Stop");
    } finally {
      super.onStop();
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
