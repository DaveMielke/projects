package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseApplication;

import java.util.concurrent.LinkedBlockingDeque;

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
    return musicLibrary;
  }

  public static BookLibrary getBookLibrary () {
    return bookLibrary;
  }

  public static RadioPrograms getRadioPrograms () {
    return radioPrograms;
  }

  private final static LinkedBlockingDeque<String> playingQueue = new LinkedBlockingDeque<>();

  public static void enqueuePlaying (String path) {
    if (path == null) path = "";
    playingQueue.offer(path);
  }

  public static String dequeuePlaying () {
    while (true) {
      try {
        return playingQueue.take();
      } catch (InterruptedException exception) {
      }
    }
  }
}
