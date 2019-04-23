package cc.mielke.dave.android.base;

import android.content.Context;
import android.os.Handler;

public abstract class BaseComponent {
  protected BaseComponent () {
    super();
  }

  protected static Context getContext () {
    return BaseApplication.getContext();
  }

  private final static Object HANDLER_LOCK = new Object();
  private static Handler handler = null;

  protected static Handler getHandler () {
    synchronized (HANDLER_LOCK) {
      if (handler == null) handler = new Handler();
      return handler;
    }
  }

  protected static void post (Runnable runnable) {
    getHandler().post(runnable);
  }

  protected static void post (long delay, Runnable runnable) {
    getHandler().postDelayed(runnable, delay);
  }

  protected static long getCurrentTime () {
    return System.currentTimeMillis();
  }
}
