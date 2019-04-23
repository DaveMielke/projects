package cc.mielke.dave.android.base;

import android.app.Activity;

import android.app.AlertDialog;
import android.content.DialogInterface;

public abstract class BaseActivity extends Activity {
  protected final AlertDialog.Builder newAlertDialogBuilder (int name) {
    AlertDialog.Builder builder = new AlertDialog.Builder(this);

    {
      StringBuilder title = new StringBuilder();

      String[] components = new String[] {
        BaseApplication.getName(this),
        (name == 0)? null: getString(name)
      };

      for (String component : components) {
        if (component == null) continue;
        if (component.isEmpty()) continue;

        if (title.length() > 0) title.append(" - ");
        title.append(component);
      }

      if (title.length() > 0) builder.setTitle(title.toString());
    }

    return builder;
  }

  protected final AlertDialog.Builder newAlertDialogBuilder () {
    return newAlertDialogBuilder(0);
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

  protected final void selectItem (int action, String[] items, DialogInterface.OnClickListener listener) {
    newAlertDialogBuilder(action)
      .setNegativeButton(android.R.string.no, null)
      .setItems(items, listener)
      .show();
  }
}
