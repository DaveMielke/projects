package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseApplication;

public class RadioApplication extends BaseApplication {
  private static MusicLibrary musicLibrary = null;
  private static BookLibrary bookLibrary = null;
  private static RadioPrograms radioPrograms = null;

  @Override
  public void onCreate () {
    super.onCreate();
    musicLibrary = new MusicLibrary();
    bookLibrary = new BookLibrary();
    radioPrograms = new RadioPrograms();
  }

  public static MusicLibrary getMusicLibrary () {
    synchronized (APPLICATION_LOCK) {
      return musicLibrary;
    }
  }

  public static BookLibrary getBookLibrary () {
    synchronized (APPLICATION_LOCK) {
      return bookLibrary;
    }
  }

  public static RadioPrograms getRadioPrograms () {
    synchronized (APPLICATION_LOCK) {
      return radioPrograms;
    }
  }
}
