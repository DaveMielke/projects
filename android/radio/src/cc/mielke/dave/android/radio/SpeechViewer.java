package cc.mielke.dave.android.radio;

public class SpeechViewer extends RadioComponent {
  public static interface OnChangeListener {
    public void onTextChange (CharSequence text);
  }

  private OnChangeListener onChangeListener = null;
  private CharSequence speechText;

  private final void onTextChange () {
    onChangeListener.onTextChange(speechText);
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
      speechText = text;

      if (onChangeListener != null) {
        getHandler().post(
          new Runnable() {
            @Override
            public void run () {
              synchronized (SpeechViewer.this) {
                onTextChange();
              }
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
