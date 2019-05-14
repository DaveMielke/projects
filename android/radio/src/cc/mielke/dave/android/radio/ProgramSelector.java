package cc.mielke.dave.android.radio;

import java.util.Map;
import java.util.HashMap;

import cc.mielke.dave.android.base.JSONLoader;
import org.json.JSONObject;
import org.json.JSONArray;

import android.util.Log;

import android.widget.Button;
import android.content.DialogInterface;

public class ProgramSelector extends ActivityComponent {
  private final static String LOG_TAG = ProgramSelector.class.getName();

  private final Button selectorButton;

  private final void updateButtonText () {
    RadioProgram program = getRadioProgram();

    if (program != null) {
      selectorButton.setText(program.getName());
    } else {
      selectorButton.setText(R.string.message_noProgram);
    }
  }

  private final void setProgram (RadioProgram program) {
    getRadioPrograms().setProgram(program);
    updateButtonText();
  }

  private final void setProgram (String name) {
    setProgram(getRadioPrograms().getProgram(name));
  }

  public ProgramSelector (MainActivity activity) {
    super(activity);

    selectorButton = mainActivity.findViewById(R.id.button_selectProgram);
    updateButtonText();
  }

  private final String[] getProgramNames () {
    String[] names = getRadioPrograms().getNames();
    if (names == null) names = new String[]{};
    return names;
  }

  private interface Action {
    public int getName ();
    public void performAction ();
  }

  private final Action actionNoProgram =
    new Action() {
      @Override
      public int getName () {
        return R.string.name_noProgram;
      }

      @Override
      public void performAction () {
        setProgram((RadioProgram)null);
      }
    };

  private final Action actionSelectStation =
    new Action() {
      @Override
      public int getName () {
        return R.string.action_selectStation;
      }

      private final Map<String, RadioProgram> stationPrograms = new HashMap<>();

      private final void selectStation (final JSONObject stations, final StringBuilder label) {
        final String[] items;

        {
          JSONArray names = stations.names();
          int count = names.length();
          items = new String[count];

          for (int index=0; index<count; index+=1) {
            items[index] = names.optString(index, "");
          }

          sort(items);
        }

        mainActivity.selectItem(
          R.string.action_selectStation, items,
          new DialogInterface.OnClickListener() {
            @Override
            public void onClick (DialogInterface dialog, int position) {
              String name = items[position];
              JSONObject station = stations.optJSONObject(name);

              if (station == null) {
                Log.w(LOG_TAG, ("station not a JSON object: " + name));
              } else {
                {
                  String string = station.optString("short", name);

                  if (!string.isEmpty()) {
                    if (label.length() > 0) label.append(' ');
                    label.append(string);
                  }
                }

                String key = "listen";
                Object object = station.opt(key);

                if (object == null) {
                  Log.w(LOG_TAG, (key + " not specified: " + name));
                } else if (object instanceof String) {
                  String url = (String)object;
                  RadioProgram program = stationPrograms.get(url);

                  if (program == null) {
                    program = new RadioProgram();
                    program.setName(label.toString());
                    program.addPlayers(new StationPlayer(url));
                    stationPrograms.put(url, program);
                  }

                  setProgram(program);
                } else if (object instanceof JSONObject) {
                  selectStation((JSONObject)object, label);
                } else {
                  Log.w(LOG_TAG, (key + " specified incorrectly: " + name));
                }
              }
            }
          }
        );
      }

      @Override
      public void performAction () {
        new JSONLoader() {
          @Override
          protected void load (JSONObject object, String name) {
            selectStation(object, new StringBuilder());
          }
        }.load(RadioParameters.RADIO_STATIONS_FILE);
      }
    };

  private final Action[] actions = new Action[] {
    actionNoProgram
  , actionSelectStation
  };

  public final void selectProgram () {
    String[] names = getProgramNames();
    sort(names);

    final int actionCount = actions.length;
    final String[] items = new String[actionCount + names.length];

    {
      int index = 0;

      for (Action action : actions) {
        items[index++] = getString(action.getName());
      }

      System.arraycopy(names, 0, items, index, names.length);
    }

    mainActivity.selectItem(
      R.string.action_selectProgram, items,
      new DialogInterface.OnClickListener() {
        @Override
        public void onClick (DialogInterface dialog, int position) {
          if (position < actionCount) {
            actions[position].performAction();
          } else {
            setProgram(items[position]);
          }
        }
      }
    );
  }
}
