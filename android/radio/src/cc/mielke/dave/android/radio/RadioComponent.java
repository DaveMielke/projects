package cc.mielke.dave.android.radio;

import java.util.ArrayList;

import android.content.Context;

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

  protected final <TYPE> TYPE removeRandomElement (ArrayList<TYPE> list) {
    if (list.isEmpty()) return null;
    int index = (int)Math.round(Math.floor((double)list.size() * Math.random()));
    return list.remove(index);
  }
}
