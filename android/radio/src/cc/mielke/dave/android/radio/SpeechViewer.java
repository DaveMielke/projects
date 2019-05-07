package cc.mielke.dave.android.radio;

public class SpeechViewer extends RadioComponent {
  public static interface OnChangeListener {
    public void onTextChange (boolean visible, CharSequence text);
  }

  private OnChangeListener onChangeListener = null;
  private boolean speechVisible = false;
  private CharSequence speechText;

  private final void onTextChange () {
    onChangeListener.onTextChange(speechVisible, speechText);
  }

  public final void setOnChangeListener (OnChangeListener listener) {
    synchronized (this) {
      onChangeListener = listener;

      if (onChangeListener != null) {
        onTextChange();
      }
    }
  }

  public final void showText (CharSequence text) {
    synchronized (this) {
      if (text == null) {
        speechVisible = false;
        speechText = "";
      } else {
        speechVisible = true;
        speechText = text;
      }

      if (onChangeListener != null) {
        getHandler().post(
          new Runnable() {
            @Override
            public void run () {
              onTextChange();
            }
          }
        );
      }

      updateNotification(speechText);
    }
  }

  public SpeechViewer () {
    super();
    showText(null);
  }
}
