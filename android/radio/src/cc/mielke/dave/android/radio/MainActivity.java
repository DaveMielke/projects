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

  public final void previousFile (View view) {
  }

  public final void playPause (View view) {
    FilePlayer.playPause();
  }

  public final void nextFile (View view) {
  }

  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);

    FilePlayer.setViewer(new FileViewer(this));
    SpeechPlayer.setViewer(new SpeechViewer(this));

    programSelector = new ProgramSelector(this);
  }

  @Override
  public void onResume () {
    super.onResume();
    FilePlayer.setVisible();
  }

  @Override
  public void onPause () {
    try {
      FilePlayer.setInvisible();
    } finally {
      super.onPause();
    }
  }
}
