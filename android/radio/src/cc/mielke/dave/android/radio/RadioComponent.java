package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseComponent;

import java.util.ArrayList;

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

  protected static <TYPE> TYPE removeRandomElement (ArrayList<TYPE> list) {
    if (list.isEmpty()) return null;
    int index = (int)Math.round(Math.floor((double)list.size() * Math.random()));
    return list.remove(index);
  }
}
