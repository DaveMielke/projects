package cc.mielke.dave.android.radio;

public class MusicLibrary extends CollectionLibrary {
  public MusicLibrary () {
    super();

    addCollection("Anthems", "/sdcard/Music/Anthems");
    addCollection("Christian", "/sdcard/Music/Christian");
    addCollection("GuyLombardo", "/sdcard/Music/Bands/GuyLombardo");
    addCollection("Portraits", "/sdcard/Music/Portraits");
  }
}
