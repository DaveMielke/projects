package cc.mielke.dave.android.radio;

public class BookLibrary extends CollectionLibrary {
  public final static String BIBLE = "The Bible";

  public BookLibrary () {
    super(RadioParameters.BOOK_LIBRARY_TYPE);
  }
}
