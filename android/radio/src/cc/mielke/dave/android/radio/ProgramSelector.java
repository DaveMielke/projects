package cc.mielke.dave.android.radio;

import android.widget.Button;
import android.content.DialogInterface;

public class ProgramSelector extends RadioComponent {
  private final MainActivity mainActivity;
  private final Button selectorButton;

  private final void showName () {
    RadioProgram program = getRadioPrograms().getProgram();

    if (program != null) {
      selectorButton.setText(program.getName());
    } else {
      selectorButton.setText(R.string.message_noProgram);
    }
  }

  public ProgramSelector (MainActivity activity) {
    super();

    mainActivity = activity;
    selectorButton = mainActivity.findViewById(R.id.button_selectProgram);

    showName();
  }

  public final void selectProgram () {
    String[] names = getRadioPrograms().getNames();
    sort(names);

    final String[] items = new String[1 + names.length];
    items[0] = getString(R.string.choice_noProgram);
    System.arraycopy(names, 0, items, 1, names.length);

    mainActivity.selectItem(
      R.string.action_selectProgram, items,
      new DialogInterface.OnClickListener() {
        @Override
        public void onClick (DialogInterface dialog, int position) {
          RadioProgram program;

          if (position == 0) {
            program = null;
          } else {
            String name = items[position];
            program = getRadioPrograms().getProgram(name);

            if (program == null) {
              mainActivity.showMessage(R.string.message_undefinedProgram, name);
              return;
            }
          }

          getRadioPrograms().setProgram(program);
          showName();
        }
      }
    );
  }
}
