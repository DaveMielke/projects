package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.BaseActivity;
import android.os.Bundle;

import android.view.View;
import android.widget.Button;

import android.content.DialogInterface;

public class MainActivity extends BaseActivity {
  private Button selectProgramButton = null;
  private RadioProgram selectedProgram = null;

  private final void showProgramName () {
    Button button = selectProgramButton;
    RadioProgram program = selectedProgram;

    if (program != null) {
      button.setText(program.getName());
    } else {
      button.setText(R.string.message_noProgram);
    }
  }

  public final void selectProgram (View view) {
    String[] names = RadioApplication.getRadioPrograms().getNames();

    final String[] items = new String[1 + names.length];
    items[0] = getString(R.string.choice_noProgram);
    System.arraycopy(names, 0, items, 1, names.length);

    selectItem(
      R.string.action_selectProgram, items,
      new DialogInterface.OnClickListener() {
        @Override
        public void onClick (DialogInterface dialog, int position) {
          if (position == 0) {
            selectedProgram = null;
          } else {
            String name = items[position];
            RadioProgram program = RadioApplication.getRadioPrograms().getProgram(name);

            if (program == null) {
              showMessage(R.string.message_undefinedProgram, name);
              return;
            }

            selectedProgram = program;
          }

          showProgramName();
          RadioApplication.getRadioPrograms().setProgram(selectedProgram);
        }
      }
    );
  }

  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);

    selectProgramButton = findViewById(R.id.button_selectProgram);
    showProgramName();
  }
}
