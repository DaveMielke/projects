package cc.mielke.dave.android.radio;

import android.widget.Button;
import android.content.DialogInterface;

public class ProgramSelector extends ActivityComponent {
  private final Button selectorButton;

  private final void updateButtonText () {
    RadioPrograms programs = getRadioPrograms();
    RadioProgram program = (programs != null)? programs.getProgram(): null;

    if (program != null) {
      selectorButton.setText(program.getName());
    } else {
      selectorButton.setText(R.string.message_noProgram);
    }
  }

  public ProgramSelector (MainActivity activity) {
    super(activity);
    selectorButton = mainActivity.findViewById(R.id.button_selectProgram);
    updateButtonText();
  }

  private final String[] getProgramNames () {
    RadioPrograms programs = getRadioPrograms();

    if (programs != null) {
      String[] names = programs.getNames();
      if (names != null) return names;
    }

    return new String[]{};
  }

  public final void selectProgram () {
    String[] names = getProgramNames();

    if (names.length == 0) {
      mainActivity.showMessage(R.string.message_noPrograms);
    } else {
      sort(names);

      final String[] items = new String[1 + names.length];
      items[0] = getString(R.string.choice_noProgram);
      System.arraycopy(names, 0, items, 1, names.length);

      mainActivity.selectItem(
        R.string.action_selectProgram, items,
        new DialogInterface.OnClickListener() {
          @Override
          public void onClick (DialogInterface dialog, int position) {
            RadioPrograms programs = getRadioPrograms();

            programs.setProgram(
              (position == 0)? null: programs.getProgram(items[position])
            );

            updateButtonText();
          }
        }
      );
    }
  }
}
