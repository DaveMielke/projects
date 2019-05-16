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
    protected Entry () {
    }
  }

  public static class Station extends Entry {
    private final String stationURL;
    private final String stationIdentifier;

    public Station (String url, String identifier) {
      super();
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

    public Group (Map<String, Entry> entries) {
      super();
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

  public final Group getRoot () {
    return rootGroup;
  }

  public final Station getStation (String identifier) {
    return identifiedStations.get(identifier);
  }

  private final Group loadGroup (JSONObject stations) {
    Map<String, Entry> entries = new HashMap<>();
    Iterator<String> iterator = stations.keys();

    while (iterator.hasNext()) {
      String name = iterator.next();
      JSONObject element = stations.optJSONObject(name);

      if (element == null) {
        Log.w(LOG_TAG, ("element not a JSON object: " + name));
      } else {
        String key = "listen";
        Object object = element.remove(key);

        if (object == null) {
          Log.w(LOG_TAG, (key + " not specified: " + name));
        } else if (object instanceof String) {
          String url = (String)object;

          String identifier = element.optString("identifier");
          if ((identifier != null) && identifier.isEmpty()) identifier = null;

          Station station = new Station(url, identifier);
          if (identifier != null) identifiedStations.put(identifier, station);
          entries.put(name, station);
        } else if (object instanceof JSONObject) {
          entries.put(name, loadGroup((JSONObject)object));
        } else {
          Log.w(LOG_TAG, (key + " specified incorrectly: " + name));
        }
      }
    }

    return new Group(entries);
  }

  private final void loadStations () {
    new JSONLoader() {
      @Override
      protected void load (JSONObject root, String name) {
        rootGroup = loadGroup(root);
      }
    }.load(RadioParameters.RADIO_STATIONS_FILE);
  }

  public RadioStations () {
    super();
    loadStations();
  }
}
