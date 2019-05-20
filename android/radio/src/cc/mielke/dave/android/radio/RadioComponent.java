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

  protected static CustomPrograms getCustomPrograms () {
    return RadioApplication.getCustomPrograms();
  }

  protected static RadioStations getRadioStations () {
    return RadioApplication.getRadioStations();
  }

  protected static RadioSchedules getRadioSchedules () {
    return RadioApplication.getRadioSchedules();
  }

  protected static void updateNotification (CharSequence title, CharSequence text) {
    RadioService.updateNotification(title, text);
  }

  protected static void updateNotification (CharSequence title) {
    updateNotification(title, null);
  }
}
