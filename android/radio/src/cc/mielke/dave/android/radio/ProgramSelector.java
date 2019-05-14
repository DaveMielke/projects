package cc.mielke.dave.android.radio;

import android.widget.Button;
import android.content.DialogInterface;

public class ProgramSelector extends ActivityComponent {
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
      private final StationSelector stationSelector = new StationSelector(mainActivity);

      @Override
      public int getName () {
        return R.string.action_selectStation;
      }

      @Override
      public void performAction () {
        stationSelector.selectStation();
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
