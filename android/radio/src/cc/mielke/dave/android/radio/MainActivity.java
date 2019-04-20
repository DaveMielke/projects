package cc.mielke.dave.android.radio;
import cc.mielke.dave.android.radio.programs.*;

import android.app.Activity;
import android.os.Bundle;

public class MainActivity extends Activity {
  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);
    RadioApplication.setProgram(new Portraits());
  }
}
