package cc.mielke.dave.android.radio;

public class CurrentSelectionWatcher extends RadioComponent {
  public static interface OnChangeListener {
    public void onProgramNameChange (String name);
    public void onScheduleNameChange (String name);
  }

  private OnChangeListener onChangeListener = null;
  private String programName;
  private String scheduleName;

  private final void onProgramNameChange () {
    onChangeListener.onProgramNameChange(programName);
  }

  private final void onScheduleNameChange () {
    onChangeListener.onScheduleNameChange(scheduleName);
  }

  public final void setOnChangeListener (OnChangeListener listener) {
    synchronized (this) {
      onChangeListener = listener;

      if (onChangeListener != null) {
        onProgramNameChange();
        onScheduleNameChange();
      }
    }
  }

  private final void updateNotification () {
    if (scheduleName != null) {
      updateNotification(scheduleName, programName);
    } else if (programName != null) {
      updateNotification(programName);
    } else {
      updateNotification(getString(R.string.state_noProgram));
    }
  }

  public final void onProgramChange (RadioProgram program) {
    synchronized (this) {
      programName = (program != null)? program.getExternalName(): null;
      if (onChangeListener != null) onProgramNameChange();
      updateNotification();
    }
  }

  public final void onScheduleChange (RadioSchedule schedule) {
    synchronized (this) {
      scheduleName = (schedule != null)? schedule.getExternalName(): null;
      if (onChangeListener != null) onScheduleNameChange();
      updateNotification();
    }
  }

  public CurrentSelectionWatcher () {
    super();
    onProgramChange(null);
    onScheduleChange(null);
  }
}
