package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import android.util.Log;

import cc.mielke.dave.android.base.JSONObjectLoader;
import org.json.JSONObject;

public class RadioStations extends RadioComponent {
  private final static String LOG_TAG = RadioStations.class.getName();

  public abstract class Entry {
    private final String entryLabel;

    protected Entry (String label) {
      entryLabel = label;
    }

    public final String getLabel () {
      return entryLabel;
    }
  }

  public class Station extends Entry {
    private final String stationURL;

    public Station (String label, String url) {
      super(label);
      stationURL = url;
    }

    public final String getURL () {
      return stationURL;
    }

    public final RadioProgram getProgram () {
      synchronized (stationPrograms) {
        RadioProgram program = stationPrograms.get(this);

        if (program == null) {
          program = new RadioProgram();
          program.setName(getLabel());
          program.addPlayers(new StationPlayer(getURL()));
          stationPrograms.put(this, program);
        }

        return program;
      }
    }
  }

  public class Group extends Entry {
    public Group (String label) {
      super(label);
    }

    private final Map<String, Entry> groupEntries = new HashMap<>();

    private final void putEntry (String name, Entry entry) {
      groupEntries.put(name, entry);
    }

    public final Entry getEntry (String name) {
      return groupEntries.get(name);
    }

    public final String[] getNames () {
      Set<String> names = groupEntries.keySet();
      return names.toArray(new String[names.size()]);
    }
  }

  private final Group rootGroup = new Group("");
  private final Map<String, Station> identifiedStations = new HashMap<>();
  private final Map<Station, RadioProgram> stationPrograms = new HashMap<>();

  public final Group getRoot () {
    return rootGroup;
  }

  public final Station getStation (String identifier) {
    return identifiedStations.get(identifier);
  }

  private final void loadStations () {
    new JSONObjectLoader() {
      private final void appendToLabel (StringBuilder label, String text) {
        if (label.length() > 0) label.append(' ');
        label.append(text);
      }

      private final void loadGroup (JSONObject stations, Group group, StringBuilder label) {
        for (String name : jsonGetKeys(stations)) {
          final int labelLength = label.length();

          try {
            JSONObject element = jsonGetObject(
              stations, name,
              ((label.length() > 0)? label: RadioParameters.RADIO_STATIONS_FILE)
            );

            if (element == null) continue;
            appendToLabel(label, name);
            final Entry oldEntry = group.getEntry(name);

            if (oldEntry != null) {
              if (!(oldEntry instanceof Group)) {
                Log.w(LOG_TAG, ("station already defined: " + label));
                continue;
              }
            }

            String key = "listen";
            Object object = element.remove(key);

            if (object == null) {
              jsonLogProblem(
                "%s not specified: %s",
                jsonKeyToString(key), label
              );
            } else if (object instanceof String) {
              String url = (String)object;
              String identifier = jsonGetString(element, "identifier", label);

              Station station = new Station(label.toString(), url);
              group.putEntry(name, station);

              if (identifier != null) {
                if (!identifier.isEmpty()) {
                  final Station oldStation = getStation(identifier);

                  if (oldStation == null) {
                    identifiedStations.put(identifier, station);
                  } else {
                    Log.w(LOG_TAG,
                      String.format(
                        "station identifier already defined: %s: %s & %s",
                        identifier, label, oldStation.getLabel()
                      )
                    );
                  }
                }
              }
            } else if (object instanceof JSONObject) {
              Group subgroup;

              {
                String text = jsonGetString(element, "within-label", label);

                if (text != null) {
                  label.setLength(labelLength);
                  appendToLabel(label, text);
                }
              }

              if (oldEntry == null) {
                subgroup = new Group(label.toString());
                group.putEntry(name, subgroup);
              } else {
                subgroup = (Group)oldEntry;
              }

              loadGroup((JSONObject)object, subgroup, label);
            } else {
              jsonLogUnexpectedType(object, key, label, String.class, JSONObject.class);
            }

            jsonLogUnhandledKeys(element, label);
          } finally {
            label.setLength(labelLength);
          }
        }
      }

      @Override
      protected void load (JSONObject root, String name) {
        loadGroup(root, rootGroup, new StringBuilder());
      }
    }.load(RadioParameters.RADIO_STATIONS_FILE);
  }

  public RadioStations () {
    super();
    loadStations();
  }
}
