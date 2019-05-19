package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseApplication;

public class RadioApplication extends BaseApplication {
  private static MusicLibrary musicLibrary = null;
  private static BookLibrary bookLibrary = null;
  private static CustomPrograms customPrograms = null;
  private static RadioStations radioStations = null;

  public static void refreshData () {
    synchronized (APPLICATION_LOCK) {
      musicLibrary = null;
      bookLibrary = null;
      customPrograms = null;
      radioStations = null;
    }
  }

  @Override
  public void onCreate () {
    super.onCreate();
  }

  public static MusicLibrary getMusicLibrary () {
    synchronized (APPLICATION_LOCK) {
      if (musicLibrary == null) musicLibrary = new MusicLibrary();
      return musicLibrary;
    }
  }

  public static BookLibrary getBookLibrary () {
    synchronized (APPLICATION_LOCK) {
      if (bookLibrary == null) bookLibrary = new BookLibrary();
      return bookLibrary;
    }
  }

  public static CustomPrograms getCustomPrograms () {
    synchronized (APPLICATION_LOCK) {
      if (customPrograms == null) customPrograms = new CustomPrograms();
      return customPrograms;
    }
  }

  public static RadioStations getRadioStations () {
    synchronized (APPLICATION_LOCK) {
      if (radioStations == null) radioStations = new RadioStations();
      return radioStations;
    }
  }
}
