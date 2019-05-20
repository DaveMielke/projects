package cc.mielke.dave.android.radio;

import java.util.List;
import java.util.LinkedList;

import java.util.Map;
import java.util.HashMap;

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
      protected abstract String format (int value);

      private static class Range {
        public final int from;
        public final int to;

        public Range (int from, int to) {
          this.from = from;
          this.to = to;
        }
      }

      private final String filterType;
      private final List<Range> filterRanges = new LinkedList<>();

      protected Filter (String type) {
        filterType = type;
      }

      private final String format (int from, int to) {
        String string = format(from);
        if (to != from) string += '-' + format(to);
        return string;
      }

      private final String format (Range range) {
        return format(range.from, range.to);
      }

      public final void addRange (int from, int to) throws RuleException {
        if (to < from) {
          throw new RuleException(
            "inverse range: %s: %s", filterType, format(from, to)
          );
        }

        for (Range range : filterRanges) {
          if ((from <= range.to) && (to >= range.from)) {
            throw new RuleException(
              "overlapping ranges: %s: %s & %s",
              filterType, format(range), format(from, to)
            );
          }
        }

        filterRanges.add(new Range(from, to));
      }
    }

    private static class TimeFilter extends Filter {
      public TimeFilter () {
        super("time");
      }

      private final static long HOURS_PER_DAY = TimeUnit.DAYS.toHours(1);
      private final static long MINUTES_PER_HOUR = TimeUnit.HOURS.toMinutes(1);
      private final static long SECONDS_PER_MINUTE = TimeUnit.MINUTES.toSeconds(1);
      private final static long MILLISECONDS_PER_SECOND = TimeUnit.SECONDS.toMillis(1);

      private static class Time {
        public int value = 0;
      }

      private final boolean add (Time time, Matcher matcher, int group, TimeUnit unit, long limit) {
        String text = matcher.group(group);
        if (text == null) return true;
        if (text.isEmpty()) return true;

        int value = Integer.valueOf(text, 10);
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
        if (!add(time, matcher, 1, TimeUnit.HOURS, HOURS_PER_DAY)) return null;
        if (!add(time, matcher, 2, TimeUnit.MINUTES, MINUTES_PER_HOUR)) return null;
        if (!add(time, matcher, 3, TimeUnit.SECONDS, SECONDS_PER_MINUTE)) return null;

        return time.value;
      }

      @Override
      protected final String format (int value) {
        long milliseconds = value % MILLISECONDS_PER_SECOND;
        value /= MILLISECONDS_PER_SECOND;

        long seconds = value % SECONDS_PER_MINUTE;
        value /= SECONDS_PER_MINUTE;

        long minutes = value % MINUTES_PER_HOUR;
        value /= MINUTES_PER_HOUR;

        StringBuilder time = new StringBuilder();
        time.append(String.format("%02d%s%02d", value, SEPARATOR, minutes));

        if ((seconds != 0) || (milliseconds != 0)) {
          time.append(String.format("%s%02d", SEPARATOR, seconds));

          if (milliseconds != 0) {
            time.append(String.format(".%03d", milliseconds));
          }
        }

        return time.toString();
      }
    }

    private static class DateFilter extends Filter {
      public DateFilter () {
        super("date");
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

      @Override
      protected final String format (int value) {
        return String.format("%d", value);
      }
    }

    private static class YearFilter extends Filter {
      public YearFilter () {
        super("year");
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

      @Override
      protected final String format (int value) {
        return String.format("%04d", value);
      }
    }

    private abstract static class EnumeratedFilter extends Filter {
      private final Enum[] enumerationValues;
      private final Map<String, Integer> nameToValue = new HashMap<>();

      private static String normalize (String name) {
        return name.toLowerCase();
      }

      public EnumeratedFilter (String type, Enum[] values) {
        super(type);

        enumerationValues = values;
        int count = values.length;

        for (int index=0; index<count; index+=1) {
          Enum value = values[index];
          Integer ordinal = index;
          String name = normalize(value.name());
          int length = name.length();

          while (length >= 3) {
            nameToValue.put(name.substring(0, length), ordinal);
            length -= 1;
          }
        }
      }

      @Override
      protected final Integer toInteger (String text) {
        return nameToValue.get(normalize(text));
      }

      @Override
      protected final String format (int value) {
        return normalize(enumerationValues[value].name()).substring(0, 3);
      }
    }

    private static class DayFilter extends EnumeratedFilter {
      private static enum DAYS {
        SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY;
      }

      public DayFilter () {
        super("day", DAYS.values());
      }
    }

    private static class MonthFilter extends EnumeratedFilter {
      private static enum MONTHS {
        JANUARY, FEBRUARY, MARCH, APRIL, MAY, JUNE,
        JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER;
      }

      public MonthFilter () {
        super("month", MONTHS.values());
      }
    }

    private final Filter timeFilter = new TimeFilter();
    private final Filter dateFilter = new DateFilter();
    private final Filter yearFilter = new YearFilter();
    private final Filter dayFilter = new DayFilter();
    private final Filter monthFilter = new MonthFilter();

    private final Filter[] allFilters = new Filter[] {
      timeFilter, dateFilter, yearFilter, dayFilter, monthFilter
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

        filter.addRange(from, to);
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
