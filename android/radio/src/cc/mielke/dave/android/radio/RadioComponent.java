package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseComponent;

public abstract class RadioComponent extends BaseComponent {
  protected RadioComponent () {
    super();
  }

  protected static MusicLibrary getMusicLibrary () {
    return RadioApplication.getMusicLibrary();
  }

  protected static BookLibrary getBookLibrary () {
    return RadioApplication.getBookLibrary();
  }

  protected static RadioStations getStations () {
    return RadioApplication.getRadioStations();
  }

  protected static RadioPrograms getPrograms () {
    return RadioApplication.getRadioPrograms();
  }

  protected static void updateNotification (CharSequence title, CharSequence text) {
    if (CurrentProgram.get() == null) {
      title = getString(R.string.state_noProgram);
      text = null;
    }

    RadioService.updateNotification(title, text);
  }

  protected static void updateNotification (CharSequence title) {
    updateNotification(title, null);
  }

  protected static void updateNotification () {
    updateNotification(null);
  }
}
