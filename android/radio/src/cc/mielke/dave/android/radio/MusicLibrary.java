package cc.mielke.dave.android.radio;

public class MusicLibrary extends CollectionLibrary {
  public MusicLibrary () {
    super();

    addCollection("Anthems", "/sdcard/Music/Anthems");
    addCollection("Bands", "/sdcard/Music/Bands");
    addCollection("Christian", "/sdcard/Music/Christian");
    addCollection("Portraits", "/sdcard/Music/Portraits");
  }
}
