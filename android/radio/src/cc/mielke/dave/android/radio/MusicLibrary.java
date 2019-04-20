package cc.mielke.dave.android.radio;

public class MusicLibrary extends AbstractLibrary {
  public MusicLibrary () {
    super();

    add("Anthems", "/sdcard/Music/Anthems");
    add("Christian", "/sdcard/Music/Christian");
    add("GuyLombardo", "/sdcard/Music/Bands/GuyLombardo");
    add("Portraits", "/sdcard/Music/Portraits");
  }
}
