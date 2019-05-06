package cc.mielke.dave.android.radio;

public class SpeechViewer extends RadioComponent {
  public static interface OnChangeListener {
    public void onTextChange (boolean visible, CharSequence text);
  }

  private OnChangeListener onChangeListener = null;

  public final void setOnChangeListener (OnChangeListener listener) {
    synchronized (this) {
      onChangeListener = listener;
    }
  }

  public final void showText (CharSequence text) {
    final boolean visible;

    if (text == null) {
      visible = false;
      text = "";
    } else {
      visible = true;
    }

    synchronized (this) {
      if (onChangeListener != null) {
        final CharSequence message = text;

        getHandler().post(
          new Runnable() {
            @Override
            public void run () {
              onChangeListener.onTextChange(visible, message);
            }
          }
        );
      }

      updateNotification(text);
    }
  }

  public SpeechViewer () {
    super();
  }
}
