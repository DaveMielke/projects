package cc.mielke.dave.android.base;

import android.os.Build;

public abstract class ApiTests {
  protected ApiTests () {
  }

  public static boolean haveLevel (int level) {
    return Build.VERSION.SDK_INT >= level;
  }

  public final static boolean haveBase =
    haveLevel(Build.VERSION_CODES.BASE);

  public final static boolean haveBase11 =
    haveLevel(Build.VERSION_CODES.BASE_1_1);

  public final static boolean haveCupcake =
    haveLevel(Build.VERSION_CODES.CUPCAKE);

  public final static boolean haveDonut =
    haveLevel(Build.VERSION_CODES.DONUT);

  public final static boolean haveEclair =
    haveLevel(Build.VERSION_CODES.ECLAIR);

  public final static boolean haveEclair01 =
    haveLevel(Build.VERSION_CODES.ECLAIR_0_1);

  public final static boolean haveEclairMR1 =
    haveLevel(Build.VERSION_CODES.ECLAIR_MR1);

  public final static boolean haveFroyo =
    haveLevel(Build.VERSION_CODES.FROYO);

  public final static boolean haveGingerbread =
    haveLevel(Build.VERSION_CODES.GINGERBREAD);

  public final static boolean haveGingerbreadMR1 =
    haveLevel(Build.VERSION_CODES.GINGERBREAD_MR1);

  public final static boolean haveHoneycomb =
    haveLevel(Build.VERSION_CODES.HONEYCOMB);

  public final static boolean haveHoneycombMR1 =
    haveLevel(Build.VERSION_CODES.HONEYCOMB_MR1);

  public final static boolean haveHoneycombMR2 =
    haveLevel(Build.VERSION_CODES.HONEYCOMB_MR2);

  public final static boolean haveIceCreamSandwich =
    haveLevel(Build.VERSION_CODES.ICE_CREAM_SANDWICH);

  public final static boolean haveIceCreamSandwichMR1 =
    haveLevel(Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1);

  public final static boolean haveJellyBean =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN);

  public final static boolean haveJellyBeanMR1 =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN_MR1);

  public final static boolean haveJellyBeanMR2 =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN_MR2);

  public final static boolean haveKitkat =
    haveLevel(Build.VERSION_CODES.KITKAT);

  public final static boolean haveKitkatWatch =
    haveLevel(Build.VERSION_CODES.KITKAT_WATCH);

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

  public final static boolean HAVE_ArrayList_sort = ApiTests.haveNougat;

  public final static boolean HAVE_OnAlarmListener = haveNougat;

  public final static boolean HAVE_AudioAttributes = haveLollipop;

  public final static boolean HAVE_AudioFocusRequest = haveOreo;
}
