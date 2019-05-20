package cc.mielke.dave.android.radio;

public class CurrentSelectionWatcher extends RadioComponent {
  public static interface OnChangeListener {
    public void onProgramChange (RadioProgram program);
    public void onScheduleChange (RadioSchedule schedule);
  }

  private OnChangeListener onChangeListener = null;
  private RadioProgram radioProgram;
  private RadioSchedule radioSchedule;

  private final void onProgramChange () {
    onChangeListener.onProgramChange(radioProgram);
  }

  private final void onScheduleChange () {
    onChangeListener.onScheduleChange(radioSchedule);
  }

  public final void setOnChangeListener (OnChangeListener listener) {
    synchronized (this) {
      onChangeListener = listener;

      if (onChangeListener != null) {
        onProgramChange();
        onScheduleChange();
      }
    }
  }

  public final void onProgramChange (RadioProgram program) {
    synchronized (this) {
      radioProgram = program;
      if (onChangeListener != null) onProgramChange();
    }
  }

  public final void onScheduleChange (RadioSchedule schedule) {
    synchronized (this) {
      radioSchedule = schedule;
      if (onChangeListener != null) onScheduleChange();
    }
  }

  public CurrentSelectionWatcher () {
    super();
    onProgramChange(null);
    onScheduleChange(null);
  }
}
