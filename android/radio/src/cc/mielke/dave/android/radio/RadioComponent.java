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

  private static Handler handler = null;

  protected final Handler getHandler () {
    synchronized (this) {
      if (handler == null) handler = new Handler();
      return handler;
    }
  }

  protected final <TYPE> TYPE removeRandomElement (ArrayList<TYPE> list) {
    if (list.isEmpty()) return null;
    int index = (int)Math.round(Math.floor((double)list.size() * Math.random()));
    return list.remove(index);
  }
}
