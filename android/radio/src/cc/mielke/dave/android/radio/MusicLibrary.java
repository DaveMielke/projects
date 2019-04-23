package cc.mielke.dave.android.radio;

public class MusicLibrary extends CollectionLibrary {
  public final static String ANTHEMS = "National Anthems";
  public final static String LOMBARDO = "Guy Lombardo";
  public final static String CHRISTIAN = "Christian Music";
  public final static String PORTRAITS = "Musical Portraits";

  public MusicLibrary () {
    super(RadioParameters.MUSIC_LIBRARY_TYPE);
  }
}
