package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.JSONLoader;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.DialogInterface;

import android.net.Uri;

public class StationSelector extends ActivityComponent {
  public StationSelector (MainActivity activity) {
    super(activity);
  }

  private final void selectStation (final JSONObject object) {
    final JSONArray names = object.names();
    final int count = names.length();
    final String[] items = new String[count];

    for (int index=0; index<count; index+=1) {
      items[index] = names.optString(index, "");
    }

    sort(items);

    mainActivity.selectItem(
      R.string.action_selectStation, items,
      new DialogInterface.OnClickListener() {
        @Override
        public void onClick (DialogInterface dialog, int position) {
          String name = items[position];

          {
            JSONObject stations = object.optJSONObject(name);

            if (stations != null) {
              selectStation(stations);
              return;
            }
          }

          {
            String url = object.optString(name, null);

            if (url != null) {
              Uri uri = Uri.parse(url);
              return;
            }
          }
        }
      }
    );
  }

  public final void selectStation () {
    new JSONLoader() {
      @Override
      protected void load (JSONObject object, String name) {
        selectStation(object);
      }
    }.load("stations");
  }
}
