package cc.mielke.dave.android.radio;

public class BookLibrary extends AbstractLibrary {
  public BookLibrary () {
    super();

    addCollection("Bible", "/sdcard/Audio/Bible");
  }
}
