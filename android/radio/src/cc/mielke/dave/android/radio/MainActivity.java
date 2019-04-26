package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseActivity;
import android.os.Bundle;

import android.view.View;

public class MainActivity extends BaseActivity {
  private ProgramSelector programSelector = null;

  public final void selectProgram (View view) {
    programSelector.selectProgram();
  }

  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);

    FilePlayer.setViewer(new FileViewer(this));
    SpeechPlayer.setViewer(new SpeechViewer(this));

    programSelector = new ProgramSelector(this);
  }
}
