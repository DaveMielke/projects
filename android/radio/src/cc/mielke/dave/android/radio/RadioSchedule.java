package cc.mielke.dave.android.radio;

import java.util.List;
import java.util.LinkedList;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import java.util.concurrent.TimeUnit;

import android.util.Log;

public class RadioSchedule extends RadioComponent {
  private final static String LOG_TAG = RadioSchedule.class.getName();

  private final String scheduleName;

  public final String getName () {
    return scheduleName;
  }

  public final String getExternalName () {
    {
      String name = getName();
      if ((name != null) && !name.isEmpty()) return name;
    }

    return getString(R.string.name_anonymousSchedule);
  }

  public static String getExternalName (RadioSchedule schedule) {
    if (schedule == null) return getString(R.string.name_noSchedule);
    return schedule.getExternalName();
  }

  private static class RuleException extends Exception {
    public RuleException (String message) {
      super(message);
    }

    public RuleException (String format, Object... arguments) {
      this(String.format(format, arguments));
    }
  }

  private static class Entry {
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

    private abstract static class Filter {
      protected abstract Integer toInteger (String text);
    }

    private static class TimeFilter extends Filter {
      public TimeFilter () {
        super();
      }

      private static class Time {
        public long value = 0;
      }

      private final boolean add (Time time, Matcher matcher, int group, TimeUnit unit, int limit) {
        String text = matcher.group(group);
        if (text == null) return false;
        if (text.isEmpty()) return false;

        long value = Integer.valueOf(text, 10);
        if (value < 0) return false;
        if (value >= limit) return false;

        time.value += unit.toMillis(value);
        return true;
      }

      private final static String VALUE = "([0-9]{2})";
      private final static String SEPARATOR = ":";

      private final static Pattern pattern = Pattern.compile(
        VALUE + SEPARATOR + VALUE + "(?:" + SEPARATOR + VALUE + ")?"
      );

      @Override
      protected final Integer toInteger (String text) {
        Matcher matcher = pattern.matcher(text);
        if (!matcher.matches()) return null;

        Time time = new Time();
        if (!add(time, matcher, 1, TimeUnit.HOURS, 24)) return null;
        if (!add(time, matcher, 2, TimeUnit.MINUTES, 60)) return null;
        if (!add(time, matcher, 3, TimeUnit.SECONDS, 60)) return null;

        return (int)time.value;
      }
    }

    private static class DateFilter extends Filter {
      public DateFilter () {
        super();
      }

      private final static Pattern pattern = Pattern.compile(
        "[1-9][0-9]?"
      );

      @Override
      protected final Integer toInteger (String text) {
        Matcher matcher = pattern.matcher(text);
        if (!matcher.matches()) return null;

        int date = Integer.valueOf(matcher.group(), 10);
        if (date < 0) return null;
        if (date > 31) return null;
        return date;
      }
    }

    private static class YearFilter extends Filter {
      public YearFilter () {
        super();
      }

      private final static Pattern pattern = Pattern.compile(
        "[0-9]{4}"
      );

      @Override
      protected final Integer toInteger (String text) {
        Matcher matcher = pattern.matcher(text);
        if (!matcher.matches()) return null;

        int year = Integer.valueOf(matcher.group(), 10);
        if (year < 1) return null;
        return year;
      }
    }

    private final Filter timeFilter = new TimeFilter();
    private final Filter dateFilter = new DateFilter();
    private final Filter yearFilter = new YearFilter();

    private final Filter[] allFilters = new Filter[] {
      timeFilter, dateFilter, yearFilter
    };

    private final void addFilter (String operand) throws RuleException {
      String start;
      String end;

      {
        int index = operand.indexOf('-');

        if (index < 0) {
          end = start = operand;
        } else {
          start = operand.substring(0, index);
          end = operand.substring(index+1);
        }
      }

      for (Filter filter : allFilters) {
        Integer from = filter.toInteger(start);
        if (from == null) continue;
        Integer to;

        if (end == start) {
          to = from;
        } else if ((to = filter.toInteger(end)) == null) {
          break;
        }

        return;
      }

      throw new RuleException("invalid filter operand: %s", operand);
    }

    public Entry (String... operands) throws RuleException {
      int count = operands.length;
      int index = 0;

      if (index == count) {
        throw new RuleException("program not specified");
      }

      radioProgram = getProgram(operands[index++]);
      while (index < count) addFilter(operands[index++]);
    }
  }

  private final List<Entry> scheduleEntries = new LinkedList<>();
  private final static char commentCharacter = '#';
  private final static Pattern operandSeparator = Pattern.compile("\\s+");

  public RadioSchedule (String name, String... rules) {
    super();
    scheduleName = name;

    for (String rule : rules) {
      {
        int index = rule.indexOf(commentCharacter);
        if (index >= 0) rule = rule.substring(0, index);
      }

      String[] operands = operandSeparator.split(rule);
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
          scheduleEntries.add(new Entry(operands));
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

  public final void start () {
  }

  public final void stop () {
  }
}
