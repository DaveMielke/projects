package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseActivity;
import android.os.Bundle;

import android.view.View;
import android.widget.Button;

public class MainActivity extends BaseActivity {
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
    setContentView(R.layout.main);

    UriPlayer.setViewer(new UriViewer(this));
    SpeechPlayer.setViewer(new SpeechViewer(this));

    programSelector = new ProgramSelector(this);

    PlayerService.start();
  }

  @Override
  public void onDestroy () {
    try {
      PlayerService.stop();
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
