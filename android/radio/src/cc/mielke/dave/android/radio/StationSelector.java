package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.JSONLoader;
import org.json.JSONObject;
import org.json.JSONException;

import android.content.DialogInterface;

public class StationSelector extends ActivityComponent {
  public StationSelector (MainActivity activity) {
    super(activity);
  }

  public final void selectStation () {
    new JSONLoader() {
      @Override
      protected void load (JSONObject json, String name) {
      }
    }.load("stations");
  }
}
