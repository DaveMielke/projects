package cc.mielke.dave.android.radio;

import android.os.AsyncTask;
import android.media.MediaMetadataRetriever;
import java.io.File;

import android.widget.TextView;

public class PlayingUpdater extends ActivityComponent {
  private TextView titleText = null;
  private TextView artistText = null;

  private final void updateText (TextView view, String text) {
    if (text == null) text = "";
    view.setText(text);
  }

  private class UpdaterTask extends AsyncTask<Object, String, Object> {
    @Override
    protected void onProgressUpdate (String... items) {
      updateText(titleText, items[0]);
      updateText(artistText, items[1]);
    }

    @Override
    protected Object doInBackground (Object... arguments) {
      while (true) {
        String path = RadioApplication.dequeuePlaying();
        String title;
        String artist;

        if (path.isEmpty()) {
          title = null;
          artist = null;
        } else {
          MediaMetadataRetriever retriever = new MediaMetadataRetriever();
          retriever.setDataSource(path);

          title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
          artist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST);

          retriever.release();
        }

        publishProgress(title, artist);
      }
    }
  }

  private final UpdaterTask updaterTask = new UpdaterTask();

  public PlayingUpdater (MainActivity activity) {
    super(activity);

    titleText = mainActivity.findViewById(R.id.text_title);
    artistText = mainActivity.findViewById(R.id.text_artist);

    updaterTask.execute();
  }
}
