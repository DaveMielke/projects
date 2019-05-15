package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseApplication;

public class RadioApplication extends BaseApplication {
  private static MusicLibrary musicLibrary = null;
  private static BookLibrary bookLibrary = null;
  private static RadioPrograms radioPrograms = null;

  public static MusicLibrary getMusicLibrary () {
    synchronized (APPLICATION_LOCK) {
      return musicLibrary;
    }
  }

  public static void setMusicLibrary (MusicLibrary library) {
    synchronized (APPLICATION_LOCK) {
      musicLibrary = library;
    }
  }

  public static void updateMusicLibrary () {
    setMusicLibrary(new MusicLibrary());
  }

  public static BookLibrary getBookLibrary () {
    synchronized (APPLICATION_LOCK) {
      return bookLibrary;
    }
  }

  public static void setBookLibrary (BookLibrary library) {
    synchronized (APPLICATION_LOCK) {
      bookLibrary = library;
    }
  }

  public static void updateBookLibrary () {
    setBookLibrary(new BookLibrary());
  }

  public static RadioPrograms getRadioPrograms () {
    synchronized (APPLICATION_LOCK) {
      return radioPrograms;
    }
  }

  public static void setRadioPrograms (RadioPrograms programs) {
    synchronized (APPLICATION_LOCK) {
      radioPrograms = programs;
    }
  }

  public static void updateRadioPrograms () {
    setRadioPrograms(new RadioPrograms());
  }

  @Override
  public void onCreate () {
    super.onCreate();
  }
}
