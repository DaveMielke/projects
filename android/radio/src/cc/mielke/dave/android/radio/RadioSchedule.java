package cc.mielke.dave.android.radio;

import java.util.List;
import java.util.LinkedList;

import java.util.regex.Pattern;

import android.util.Log;

public class RadioSchedule extends RadioComponent {
  private final static String LOG_TAG = RadioSchedule.class.getName();

  private static class RuleException extends Exception {
    public RuleException (String message) {
      super(message);
    }

    public RuleException (String format, Object... arguments) {
      this(String.format(format, arguments));
    }
  }

  private static class Component extends RadioComponent {
    private final RadioProgram radioProgram;

    private static RadioProgram getProgram (String identifier) throws RuleException {
      {
        RadioStations stations = getRadioStations();
        RadioStations.Station station = stations.getStation(identifier);
        if (station != null) return stations.getProgram(station);
      }

      {
        RadioProgram program = getCustomPrograms().getProgramByIdentifier(identifier);
        if (program != null) return program;
      }

      throw new RuleException("program not defined");
    }

    public Component (String... operands) throws RuleException {
      int count = operands.length;
      int index = 0;

      if (index == count) {
        throw new RuleException("program not specified");
      }

      radioProgram = getProgram(operands[index++]);

      while (index < count) {
        index += 1;
      }
    }
  }

  private final List<Component> scheduleComponents = new LinkedList<>();
  private final static char commentCharacter = '#';
  private final static Pattern splitPattern = Pattern.compile("\\s+");

  public RadioSchedule (String... rules) {
    super();

    for (String rule : rules) {
      {
        int index = rule.indexOf(commentCharacter);
        if (index >= 0) rule = rule.substring(0, index);
      }

      String[] operands = splitPattern.split(rule);
      int count = operands.length;
      int index = 0;

      if (index < count) {
        if (operands[index].isEmpty()) {
          index += 1;
        }
      }

      if (index < count) {
        if (index > 0) {
          int newCount = count - index;
          String[] newOperands = new String[newCount];
          System.arraycopy(operands, index, newOperands, 0, newCount);
          operands = newOperands;
        }

        try {
          scheduleComponents.add(new Component(operands));
        } catch (RuleException exception) {
          Log.w(LOG_TAG,
            String.format(
              "syntax error: %s: %s",
              exception.getMessage(), rule
            )
          );
        }
      }
    }
  }
}
