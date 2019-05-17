package cc.mielke.dave.android.radio;

import android.util.Log;
import android.os.AsyncTask;

import android.widget.Button;
import android.content.DialogInterface;

public class ProgramSelector extends ActivityComponent {
  private final static String LOG_TAG = ProgramSelector.class.getName();

  private final Button selectorButton;

  private final void updateButtonText (RadioProgram program) {
    if (program != null) {
      selectorButton.setText(program.getName());
    } else {
      selectorButton.setText(R.string.message_noProgram);
    }
  }

  private final void updateButtonText () {
    updateButtonText(CurrentProgram.get());
  }

  private final void setProgram (RadioProgram program) {
    CurrentProgram.set(program);
    updateButtonText(program);
  }

  private final void setProgram (String name) {
    setProgram(getPrograms().getProgram(name));
  }

  public ProgramSelector (MainActivity activity) {
    super(activity);

    selectorButton = mainActivity.findViewById(R.id.button_selectProgram);
    updateButtonText();
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

      private final void selectStation (final RadioStations.Group group) {
        final String[] names = group.getNames();
        sort(names);

        mainActivity.selectItem(
          R.string.action_selectStation, names,
          new DialogInterface.OnClickListener() {
            @Override
            public void onClick (DialogInterface dialog, int position) {
              String name = names[position];
              RadioStations.Entry entry = group.getEntry(name);

              if (entry instanceof RadioStations.Station) {
                setProgram(((RadioStations.Station)entry).getProgram());
              } else if (entry instanceof RadioStations.Group) {
                selectStation((RadioStations.Group)entry);
              }
            }
          }
        );
      }

      @Override
      public void performAction () {
        new AsyncTask<Object, Object, RadioStations>() {
          @Override
          protected RadioStations doInBackground (Object... arguments) {
            return getStations();
          }

          @Override
          protected void onPostExecute (RadioStations stations) {
            selectStation(stations.getRoot());
          }
        }.execute();
      }
    };

  private final Action[] actions = new Action[] {
    actionNoProgram
  , actionSelectStation
  };

  public final void selectProgram () {
    new AsyncTask<Object, Object, RadioPrograms>() {
      @Override
      protected RadioPrograms doInBackground (Object... arguments) {
        RadioApplication.refresh();
        return getPrograms();
      }

      @Override
      protected void onPostExecute (RadioPrograms programs) {
        String[] names = programs.getNames();
        if (names == null) names = new String[0];
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
    }.execute();
  }
}
