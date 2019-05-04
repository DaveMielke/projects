package cc.mielke.dave.android.base;

import android.os.Build;

public abstract class ApiTests {
  protected ApiTests () {
  }

  public static boolean haveLevel (int level) {
    return Build.VERSION.SDK_INT >= level;
  }

  public final static boolean haveJellyBean =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN);

  public final static boolean haveJellyBeanMR1 =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN_MR1);

  public final static boolean haveJellyBeanMR2 =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN_MR2);

  public final static boolean haveKitkat =
    haveLevel(Build.VERSION_CODES.KITKAT);

  public final static boolean haveLollipop =
    haveLevel(Build.VERSION_CODES.LOLLIPOP);

  public final static boolean haveLollipopMR1 =
    haveLevel(Build.VERSION_CODES.LOLLIPOP_MR1);

  public final static boolean haveMarshmallow =
    haveLevel(Build.VERSION_CODES.M);

  public final static boolean haveNougat =
    haveLevel(Build.VERSION_CODES.N);

  public final static boolean haveNougatMR1 =
    haveLevel(Build.VERSION_CODES.N_MR1);

  public final static boolean haveOreo =
    haveLevel(Build.VERSION_CODES.O);

  public final static boolean haveOreoMR1 =
    haveLevel(Build.VERSION_CODES.O_MR1);

  public final static boolean havePie =
    haveLevel(Build.VERSION_CODES.P);

  public final static boolean HAVE_OnAlarmListener = haveNougat;

  public final static boolean HAVE_AudioAttributes = haveLollipop;

  public final static boolean HAVE_AudioFocusRequest = haveOreo;
}
