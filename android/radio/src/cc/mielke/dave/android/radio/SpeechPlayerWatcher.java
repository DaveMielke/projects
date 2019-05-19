package cc.mielke.dave.android.radio;

public class SpeechPlayerWatcher extends RadioComponent {
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
              synchronized (SpeechPlayerWatcher.this) {
                onTextChange();
              }
            }
          }
        );
      }

      updateNotification(speechText);
    }
  }

  public SpeechPlayerWatcher () {
    super();
    onTextChange(null);
  }
}
