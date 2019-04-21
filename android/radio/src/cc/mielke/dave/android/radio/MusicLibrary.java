package cc.mielke.dave.android.radio;

public class MusicLibrary extends CollectionLibrary {
  public final static String ANTHEMS = "National Anthems";
  public final static String BANDS = "Big Bands";
  public final static String CHRISTIAN = "Christian Music";
  public final static String PORTRAITS = "Musical Portraits";

  public MusicLibrary () {
    super();

    addCollection(ANTHEMS, "/sdcard/Music/Anthems");
    addCollection(BANDS, "/sdcard/Music/Bands");
    addCollection(CHRISTIAN, "/sdcard/Music/Christian");
    addCollection(PORTRAITS, "/sdcard/Music/Portraits");
  }
}
