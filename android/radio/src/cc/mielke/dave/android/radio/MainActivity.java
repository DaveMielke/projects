package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.*;
import cc.mielke.dave.android.radio.programs.*;

import java.util.Map;
import java.util.HashMap;

import android.os.Bundle;

import android.view.View;
import android.widget.Button;

import android.content.DialogInterface;

public class MainActivity extends BaseActivity {
  private Button selectProgramButton = null;
  private RadioProgram selectedProgram = null;
  private final Map<String, RadioProgram> programCache = new HashMap<>();

  private final String[] getProgramNames () {
    return getResources().getStringArray(R.array.programs);
  }

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
    String[] names = getProgramNames();

    final String[] items = new String[1 + names.length];
    items[0] = getString(R.string.choice_noProgram);
    System.arraycopy(names, 0, items, 1, names.length);

    selectItem(
      items,
      new DialogInterface.OnClickListener() {
        @Override
        public void onClick (DialogInterface dialog, int position) {
          if (position == 0) {
            selectedProgram = null;
          } else {
            String name = items[position];
            RadioProgram program = programCache.get(name);

            if (program == null) {
              Class type;

              try {
                type = Class.forName(
                  getClass().getPackage().getName() + ".programs." + name.replace(" ", "")
                );
              } catch (ClassNotFoundException exception) {
                showMessage(R.string.message_undefinedProgram, name);
                return;
              }

              try {
                program = (RadioProgram)type.newInstance();
              } catch (IllegalAccessException exception) {
                showMessage(R.string.message_inaccessibleProgram, name);
                return;
              } catch (InstantiationException exception) {
                showMessage(R.string.message_uninstantiatableProgram, name);
                return;
              } catch (ClassCastException exception) {
                showMessage(R.string.message_notProgram, name);
                return;
              }

              programCache.put(name, program);
            }

            selectedProgram = program;
          }

          showProgramName();
          RadioApplication.setProgram(selectedProgram);
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
