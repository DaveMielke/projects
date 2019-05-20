package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class CurrentSelection extends RadioComponent {
  private final static String LOG_TAG = CurrentSelection.class.getName();

  protected CurrentSelection () {
    super();
  }

  protected final static CurrentSelectionWatcher watcher = new CurrentSelectionWatcher();

  public static CurrentSelectionWatcher getWatcher () {
    return watcher;
  }

  protected static void logSelectionChange (String what, String oldName, String newName) {
    Log.i(LOG_TAG,
      String.format(
        "changing %s: %s -> %s",
        what, oldName, newName
      )
    );
  }
}
