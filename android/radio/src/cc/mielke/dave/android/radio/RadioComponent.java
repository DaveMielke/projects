package cc.mielke.dave.android.radio;

import java.util.ArrayList;

import android.content.Context;
import android.os.Handler;

public class RadioComponent {
  protected RadioComponent () {
    super();
  }

  protected static Context getContext () {
    return RadioApplication.getContext();
  }

  protected static long getCurrentTime () {
    return System.currentTimeMillis();
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

  protected final <TYPE> TYPE removeRandomElement (ArrayList<TYPE> list) {
    if (list.isEmpty()) return null;
    int index = (int)Math.round(Math.floor((double)list.size() * Math.random()));
    return list.remove(index);
  }
}
