package cc.mielke.dave.android.radio;

import android.view.View;
import android.widget.TextView;

public class SpeechViewer extends ActivityComponent {
  private View speechView = null;
  private TextView speechText = null;

  public final void showText (CharSequence text) {
    boolean visible;

    if (text == null) {
      visible = false;
      text = "";
    } else {
      visible = true;
    }

    setVisible(speechView, visible);
    speechText.setText(text);
  }

  public SpeechViewer (MainActivity activity) {
    super(activity);

    speechView = mainActivity.findViewById(R.id.view_speech);
    speechText = mainActivity.findViewById(R.id.speech_text);
  }
}
