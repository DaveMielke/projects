package cc.mielke.dave.android.base;

import android.app.Activity;

import android.app.AlertDialog;
import android.content.DialogInterface;

public abstract class BaseActivity extends Activity {
  protected final AlertDialog.Builder newAlertDialogBuilder () {
    AlertDialog.Builder builder = new AlertDialog.Builder(this);
    return builder;
  }

  protected final void showMessage (String message, String... details) {
    if (details.length > 0) {
      StringBuilder text = new StringBuilder(message);

      for (String detail : details) {
        if (detail == null) continue;
        if (detail.isEmpty()) continue;

        text.append(": ");
        text.append(detail);
      }

      message = text.toString();
    }

    newAlertDialogBuilder()
      .setNeutralButton(android.R.string.yes, null)
      .setMessage(message)
      .show();
  }

  protected final void showMessage (int message, String... details) {
    showMessage(getString(message), details);
  }

  protected final void selectItem (String[] items, DialogInterface.OnClickListener listener) {
    newAlertDialogBuilder()
      .setNegativeButton(android.R.string.no, null)
      .setItems(items, listener)
      .show();
  }
}
