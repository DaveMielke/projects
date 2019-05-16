package cc.mielke.dave.android.radio;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;

import android.util.Log;

import cc.mielke.dave.android.base.JSONLoader;
import org.json.JSONObject;

public class RadioStations extends RadioComponent {
  private final static String LOG_TAG = RadioStations.class.getName();

  public abstract static class Entry {
    private final String entryLabel;

    protected Entry (String label) {
      entryLabel = label;
    }

    public final String getLabel () {
      return entryLabel;
    }
  }

  public static class Station extends Entry {
    private final String stationURL;
    private final String stationIdentifier;

    public Station (String label, String url, String identifier) {
      super(label);
      stationURL = url;
      stationIdentifier = identifier;
    }

    public final String getURL () {
      return stationURL;
    }

    public final String getIdentifier () {
      return stationIdentifier;
    }
  }

  public static class Group extends Entry {
    private final Map<String, Entry> groupEntries;

    public Group (String label, Map<String, Entry> entries) {
      super(label);
      groupEntries = entries;
    }

    public final String[] getNames () {
      Set<String> names = groupEntries.keySet();
      return names.toArray(new String[names.size()]);
    }

    public final Entry getEntry (String name) {
      return groupEntries.get(name);
    }
  }

  private Group rootGroup = null;
  private final Map<String, Station> identifiedStations = new HashMap<>();
  private final Map<String, RadioProgram> radioPrograms = new HashMap<>();

  public final Group getRoot () {
    return rootGroup;
  }

  public final Station getStation (String identifier) {
    return identifiedStations.get(identifier);
  }

  public final RadioProgram getProgram (Station station) {
    String url = station.getURL();

    synchronized (radioPrograms) {
      RadioProgram program = radioPrograms.get(url);

      if (program == null) {
        program = new RadioProgram();
        program.setName(station.getLabel());
        program.addPlayers(new StationPlayer(url));
        radioPrograms.put(url, program);
      }

      return program;
    }
  }

  private final Group loadGroup (JSONObject stations, StringBuilder label) {
    Map<String, Entry> entries = new HashMap<>();
    Iterator<String> iterator = stations.keys();

    while (iterator.hasNext()) {
      String name = iterator.next();
      JSONObject element = stations.optJSONObject(name);

      if (element == null) {
        Log.w(LOG_TAG, ("element not a JSON object: " + name));
      } else {
        int labelLength = label.length();

        {
          String component = element.optString("label-component", name);

          if (!component.isEmpty()) {
            if (label.length() > 0) label.append(' ');
            label.append(component);
          }
        }

        String key = "listen";
        Object object = element.remove(key);

        if (object == null) {
          Log.w(LOG_TAG, (key + " not specified: " + name));
        } else if (object instanceof String) {
          String url = (String)object;

          String identifier = element.optString("identifier");
          if ((identifier != null) && identifier.isEmpty()) identifier = null;

          Station station = new Station(label.toString(), url, identifier);
          if (identifier != null) identifiedStations.put(identifier, station);
          entries.put(name, station);
        } else if (object instanceof JSONObject) {
          entries.put(name, loadGroup((JSONObject)object, label));
        } else {
          Log.w(LOG_TAG, (key + " specified incorrectly: " + name));
        }

        label.setLength(labelLength);
      }
    }

    return new Group(label.toString(), entries);
  }

  private final void loadStations () {
    new JSONLoader() {
      @Override
      protected void load (JSONObject root, String name) {
        rootGroup = loadGroup(root, new StringBuilder());
      }
    }.load(RadioParameters.RADIO_STATIONS_FILE);
  }

  public RadioStations () {
    super();
    loadStations();
  }
}
