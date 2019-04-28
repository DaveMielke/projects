package cc.mielke.dave.android.radio;

import android.view.View;
import android.widget.TextView;

public class SpeechViewer extends ActivityComponent {
  private View speechView = null;
  private TextView speechText = null;

  public final void showText (CharSequence text) {
    final boolean visible;

    if (text == null) {
      visible = false;
      text = "";
    } else {
      visible = true;
    }

    final CharSequence message = text;

    handler.post(
      new Runnable() {
        @Override
        public void run () {
          setVisible(speechView, visible);
          speechText.setText(message);
        }
      }
    );
  }

  public SpeechViewer (MainActivity activity) {
    super(activity);

    speechView = mainActivity.findViewById(R.id.view_speech);
    speechText = mainActivity.findViewById(R.id.speech_text);
  }
}
