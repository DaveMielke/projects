package cc.mielke.dave.android.radio;

public class SpeechWatcher extends RadioComponent {
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

  public final void onTextChange (CharSequence text) {
    synchronized (this) {
      speechText = text;

      if (onChangeListener != null) {
        getHandler().post(
          new Runnable() {
            @Override
            public void run () {
              synchronized (SpeechWatcher.this) {
                onTextChange();
              }
            }
          }
        );
      }

      updateNotification(speechText);
    }
  }

  public SpeechWatcher () {
    super();
    onTextChange(null);
  }
}
