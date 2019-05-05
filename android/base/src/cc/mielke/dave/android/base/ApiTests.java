package cc.mielke.dave.android.base;

import android.os.Build;

public abstract class ApiTests {
  protected ApiTests () {
  }

  public static boolean haveLevel (int level) {
    return Build.VERSION.SDK_INT >= level;
  }

  // API level 1 - Android 1.0
  public final static boolean haveBase =
    haveLevel(Build.VERSION_CODES.BASE);

  // API level 2 - Android 1.1
  public final static boolean haveBase11 =
    haveLevel(Build.VERSION_CODES.BASE_1_1);

  // API level 3 - Android 1.5
  public final static boolean haveCupcake =
    haveLevel(Build.VERSION_CODES.CUPCAKE);

  // API level 4 - Android 1.6
  public final static boolean haveDonut =
    haveLevel(Build.VERSION_CODES.DONUT);

  // API level 5 - Android 2.0
  public final static boolean haveEclair =
    haveLevel(Build.VERSION_CODES.ECLAIR);

  // API level 6 - Android 2.0.1
  public final static boolean haveEclair01 =
    haveLevel(Build.VERSION_CODES.ECLAIR_0_1);

  // API level 7 - Android 2.1
  public final static boolean haveEclairMR1 =
    haveLevel(Build.VERSION_CODES.ECLAIR_MR1);

  // API level 8 - Android 2.2
  public final static boolean haveFroyo =
    haveLevel(Build.VERSION_CODES.FROYO);

  // API level 9 - Android 2.3
  public final static boolean haveGingerbread =
    haveLevel(Build.VERSION_CODES.GINGERBREAD);

  // API level 10 - Android 2.3.3
  public final static boolean haveGingerbreadMR1 =
    haveLevel(Build.VERSION_CODES.GINGERBREAD_MR1);

  // API level 11 - Android 3.0
  public final static boolean haveHoneycomb =
    haveLevel(Build.VERSION_CODES.HONEYCOMB);

  // API level 12 - Android 3.1
  public final static boolean haveHoneycombMR1 =
    haveLevel(Build.VERSION_CODES.HONEYCOMB_MR1);

  // API level 13 - Android 3.2
  public final static boolean haveHoneycombMR2 =
    haveLevel(Build.VERSION_CODES.HONEYCOMB_MR2);

  // API level 14 - Android 4.0
  public final static boolean haveIceCreamSandwich =
    haveLevel(Build.VERSION_CODES.ICE_CREAM_SANDWICH);

  // API level 15 - Android 4.0.3
  public final static boolean haveIceCreamSandwichMR1 =
    haveLevel(Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1);

  // API level 16 - Android 4.1
  public final static boolean haveJellyBean =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN);

  // API level 17 - Android 4.2
  public final static boolean haveJellyBeanMR1 =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN_MR1);

  // API level 18 - Android 4.3
  public final static boolean haveJellyBeanMR2 =
    haveLevel(Build.VERSION_CODES.JELLY_BEAN_MR2);

  // API level 19 - Android 4.4
  public final static boolean haveKitkat =
    haveLevel(Build.VERSION_CODES.KITKAT);

  // API level 20 - Android 4.4W
  public final static boolean haveKitkatWatch =
    haveLevel(Build.VERSION_CODES.KITKAT_WATCH);

  // API level 21 - Android 5.0
  public final static boolean haveLollipop =
    haveLevel(Build.VERSION_CODES.LOLLIPOP);

  // API level 22 - Android 5.1
  public final static boolean haveLollipopMR1 =
    haveLevel(Build.VERSION_CODES.LOLLIPOP_MR1);

  // API level 23 - Android 6.0
  public final static boolean haveMarshmallow =
    haveLevel(Build.VERSION_CODES.M);

  // API level 24 - Android 7.0
  public final static boolean haveNougat =
    haveLevel(Build.VERSION_CODES.N);

  // API level 25 - Android 7.1
  public final static boolean haveNougatMR1 =
    haveLevel(Build.VERSION_CODES.N_MR1);

  // API level 26 - Android 8.0
  public final static boolean haveOreo =
    haveLevel(Build.VERSION_CODES.O);

  // API level 27 - Android 8.1
  public final static boolean haveOreoMR1 =
    haveLevel(Build.VERSION_CODES.O_MR1);

  // API level 28 - Android 9.0
  public final static boolean havePie =
    haveLevel(Build.VERSION_CODES.P);

  public final static boolean HAVE_ArrayList_sort = ApiTests.haveNougat;

  public final static boolean HAVE_AlarmManager_OnAlarmListener = haveNougat;

  public final static boolean HAVE_AudioAttributes = haveLollipop;

  public final static boolean HAVE_AudioFocusRequest = haveOreo;

  public final static boolean HAVE_Notification_Action = haveKitkatWatch;

  public final static boolean HAVE_Notification_Builder_setActions = haveNougat;
}
