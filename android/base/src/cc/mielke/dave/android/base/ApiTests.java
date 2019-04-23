package cc.mielke.dave.android.base;

import android.os.Build;

public abstract class ApiTests {
  protected ApiTests () {
  }

  public static boolean haveAndroidSDK (int sdk) {
    return Build.VERSION.SDK_INT >= sdk;
  }

  public final static boolean haveJellyBean =
    haveAndroidSDK(Build.VERSION_CODES.JELLY_BEAN);

  public final static boolean haveJellyBeanMR1 =
    haveAndroidSDK(Build.VERSION_CODES.JELLY_BEAN_MR1);

  public final static boolean haveJellyBeanMR2 =
    haveAndroidSDK(Build.VERSION_CODES.JELLY_BEAN_MR2);

  public final static boolean haveKitkat =
    haveAndroidSDK(Build.VERSION_CODES.KITKAT);

  public final static boolean haveLollipop =
    haveAndroidSDK(Build.VERSION_CODES.LOLLIPOP);

  public final static boolean haveLollipopMR1 =
    haveAndroidSDK(Build.VERSION_CODES.LOLLIPOP_MR1);

  public final static boolean haveMarshmallow =
    haveAndroidSDK(Build.VERSION_CODES.M);

  public final static boolean haveNougat =
    haveAndroidSDK(Build.VERSION_CODES.N);

  public final static boolean haveNougatMR1 =
    haveAndroidSDK(Build.VERSION_CODES.N_MR1);

  public final static boolean haveOreo =
    haveAndroidSDK(Build.VERSION_CODES.O);
}
