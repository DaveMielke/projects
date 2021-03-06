package cc.mielke.dave.android.base;

import android.app.Activity;
import android.os.Bundle;

import android.app.AlertDialog;
import android.content.DialogInterface;

import android.view.View;

public abstract class BaseActivity extends Activity {
  @Override
  protected void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    BaseApplication.setContext(this);
  }

  public final AlertDialog.Builder newAlertDialogBuilder (int name) {
    StringBuilder title = new StringBuilder();
    {
      String[] components = new String[] {
        BaseApplication.getName(this),
        getString(name)
      };

      for (String component : components) {
        if (title.length() > 0) title.append(" - ");
        title.append(component);
      }
    }

    return new AlertDialog.Builder(this)
      .setTitle(title.toString())
      ;
  }

  public final AlertDialog.Builder newAlertDialogBuilder () {
    return newAlertDialogBuilder(0);
  }

  public final void showMessage (String message, String... details) {
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

  public final void showMessage (int message, String... details) {
    showMessage(getString(message), details);
  }

  public final void selectItem (int action, String[] items, DialogInterface.OnClickListener listener) {
    newAlertDialogBuilder(action)
      .setNegativeButton(android.R.string.no, null)
      .setItems(items, listener)
      .show();
  }

  public final void setVisible (View view, boolean yes) {
    int newVisibility = yes? View.VISIBLE: View.GONE;

    if (newVisibility != view.getVisibility()) {
      view.setVisibility(newVisibility);
    }
  }
}
