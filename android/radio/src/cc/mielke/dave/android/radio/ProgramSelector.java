package cc.mielke.dave.android.radio;

import android.util.Log;
import android.os.AsyncTask;
import android.content.DialogInterface;

public class ProgramSelector extends ActivityComponent {
  private final static String LOG_TAG = ProgramSelector.class.getName();

  private final void setProgram (RadioProgram program) {
    CurrentProgram.setProgram(program);
  }

  private final void setProgram (String name) {
    setProgram(getCustomPrograms().getProgram(name));
  }

  public ProgramSelector (MainActivity activity) {
    super(activity);
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
                RadioStations.Station station = (RadioStations.Station)entry;
                setProgram(getRadioStations().getProgram(station));
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
            return getRadioStations();
          }

          @Override
          protected void onPostExecute (RadioStations stations) {
            selectStation(stations.getRoot());
          }
        }.execute();
      }
    };

  private final Action actionSelectSchedule =
    new Action() {
      @Override
      public int getName () {
        return R.string.action_selectSchedule;
      }

      @Override
      public void performAction () {
        new AsyncTask<Object, Object, RadioSchedules>() {
          @Override
          protected RadioSchedules doInBackground (Object... arguments) {
            return getRadioSchedules();
          }

          @Override
          protected void onPostExecute (final RadioSchedules schedules) {
            final String[] names = schedules.getNames();
            sort(names);

            mainActivity.selectItem(
              R.string.action_selectSchedule, names,
              new DialogInterface.OnClickListener() {
                @Override
                public void onClick (DialogInterface dialog, int position) {
                  String name = names[position];
                  RadioSchedule schedule = getRadioSchedules().getSchedule(name);
                  CurrentSchedule.setSchedule(schedule);
                }
              }
            );
          }
        }.execute();
      }
    };

  private final Action[] actions = new Action[] {
    actionNoProgram
  , actionSelectStation
  , actionSelectSchedule
  };

  public final void selectProgram () {
    new AsyncTask<Object, Object, CustomPrograms>() {
      @Override
      protected CustomPrograms doInBackground (Object... arguments) {
        RadioApplication.refreshData();
        return getCustomPrograms();
      }

      @Override
      protected void onPostExecute (CustomPrograms programs) {
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
