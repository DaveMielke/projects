package cc.mielke.dave.android.radio;

import android.net.Uri;
import android.media.AudioAttributes;

public class StationPlayer extends UriPlayer {
  private final static String LOG_TAG = StationPlayer.class.getName();

  private final Uri stationUri;

  @Override
  public final boolean play () {
    return play(stationUri, AudioAttributes.CONTENT_TYPE_MUSIC);
  }

  public StationPlayer (Uri uri) {
    super();
    stationUri = uri;
    setBaseDelay(RadioParameters.STATION_RETRY_DELAY);
  }

  public StationPlayer (String url) {
    this(Uri.parse(url));
  }
}
