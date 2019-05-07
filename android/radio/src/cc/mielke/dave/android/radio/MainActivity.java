package cc.mielke.dave.android.radio;

import cc.mielke.dave.android.base.ApiTests;
import static cc.mielke.dave.android.base.TimeConstants.*;

import android.util.Log;

import cc.mielke.dave.android.base.BaseActivity;
import android.os.Bundle;
import android.content.Intent;

import android.view.View;
import android.widget.TextView;
import android.widget.Button;
import android.widget.SeekBar;

public class MainActivity extends BaseActivity {
  private final static String LOG_TAG = MainActivity.class.getName();

  private final void updateText (TextView view, CharSequence text) {
    if (text == null) text = "";
    view.setText(text);
    setVisible(view, (text.length() > 0));
  }

  private View uriMetadataView = null;
  private TextView uriMetadataTitle = null;
  private TextView uriMetadataArtist = null;

  private View uriButtonsView = null;
  private Button uriPlayPauseButton = null;

  private View uriSeekView = null;
  private SeekBar uriSeekBar = null;
  private TextView uriSeekCurrent = null;
  private TextView uriSeekRemaining = null;

  private final UriViewer.OnChangeListener uriChangeListener =
    new UriViewer.OnChangeListener() {
      @Override
      public void onMetadataChange (boolean visible, CharSequence title, CharSequence artist) {
        setVisible(uriMetadataView, visible);
        updateText(uriMetadataTitle, title);
        updateText(uriMetadataArtist, artist);
      }

      @Override
      public void onPlayPauseChange (Boolean isPlaying) {
        boolean visible = isPlaying != null;
        if (!visible) isPlaying = false;

        int label;
        int image;

        if (isPlaying) {
          label = R.string.action_uriPause;
          image = android.R.drawable.ic_media_pause;
        } else {
          label = R.string.action_uriPlay;
          image = android.R.drawable.ic_media_play;
        }

        setVisible(uriButtonsView, visible);
        uriPlayPauseButton.setContentDescription(getString(label));
        uriPlayPauseButton.setBackgroundResource(image);
      }

      private final String toTime (long milliseconds) {
        StringBuilder time = new StringBuilder();

        long seconds = (milliseconds + (SECOND.HALF - 1)) / SECOND.ONE;
        long minutes = seconds / SECONDS_PER_MINUTE;
        seconds %= SECONDS_PER_MINUTE;

        long hours = minutes / MINUTES_PER_HOUR;
        minutes %= MINUTES_PER_HOUR;

        if (hours > 0) {
          time.append(String.format("%d:%02d", hours, minutes));
        } else {
          time.append(String.format("%d", minutes));
        }

        time.append(String.format(":%02d", seconds));
        return time.toString();
      }

      @Override
      public void onPositionChange (int milliseconds) {
        if (ApiTests.haveNougat) {
          uriSeekBar.setProgress(milliseconds, true);
        } else {
          uriSeekBar.setProgress(milliseconds);
        }

        uriSeekCurrent.setText(toTime(milliseconds));
        uriSeekRemaining.setText("-" + toTime(uriSeekBar.getMax() - milliseconds));
      }

      @Override
      public void onDurationChange (int milliseconds) {
        boolean visible = milliseconds > 0;
        setVisible(uriSeekView, visible);
        uriSeekBar.setMax(milliseconds);
        if (!visible) uriSeekBar.setProgress(0);
      }
    };

  private final SeekBar.OnSeekBarChangeListener uriSeekBarChangeListener =
    new SeekBar.OnSeekBarChangeListener() {
      @Override
      public void onProgressChanged (SeekBar seekBar, int position, boolean fromUser) {
        if (fromUser) {
          UriPlayer.setPosition(position);
        }
      }

      @Override
      public void onStartTrackingTouch (SeekBar seekBar) {
        PositionMonitor.StopReason.TOUCH.stop();
      }

      @Override
      public void onStopTrackingTouch (SeekBar seekBar) {
        PositionMonitor.StopReason.TOUCH.start();
      }
    };

  private View speechView = null;
  private TextView speechText = null;

  private final SpeechViewer.OnChangeListener speechChangeListener =
    new SpeechViewer.OnChangeListener() {
      @Override
      public void onTextChange (CharSequence text) {
        boolean visible = text != null;
        setVisible(speechView, visible);
        updateText(speechText, text);
      }
    };

  private ProgramSelector programSelector = null;

  public final void selectProgram (View view) {
    programSelector.selectProgram();
  }

  public final void uriPlayPause (View view) {
    RadioPlayer.Action.PLAY_PAUSE.perform();
  }

  public final void uriNext (View view) {
    RadioPlayer.Action.NEXT.perform();
  }

  public final void uriPrevious (View view) {
    RadioPlayer.Action.PREVIOUS.perform();
  }

  @Override
  public void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);

    uriMetadataView = findViewById(R.id.uri_metadata_view);
    uriMetadataTitle = findViewById(R.id.uri_metadata_title);
    uriMetadataArtist = findViewById(R.id.uri_metadata_artist);

    uriButtonsView = findViewById(R.id.uri_buttons_view);
    uriPlayPauseButton = findViewById(R.id.uri_button_PlayPause);

    uriSeekView = findViewById(R.id.uri_seek_view);
    uriSeekBar = findViewById(R.id.uri_seek_bar);
    uriSeekCurrent = findViewById(R.id.uri_seek_current);
    uriSeekRemaining = findViewById(R.id.uri_seek_remaining);

    uriSeekBar.setKeyProgressIncrement((int)RadioParameters.USER_SEEK_INCREMENT);
    uriSeekBar.setOnSeekBarChangeListener(uriSeekBarChangeListener);

    speechView = findViewById(R.id.view_speech);
    speechText = findViewById(R.id.speech_text);

    UriPlayer.getViewer().setOnChangeListener(uriChangeListener);
    SpeechPlayer.getViewer().setOnChangeListener(speechChangeListener);

    programSelector = new ProgramSelector(this);

    RadioService.start();
  }

  @Override
  protected void onNewIntent (Intent intent) {
  }

  @Override
  public void onDestroy () {
    try {
      UriPlayer.getViewer().setOnChangeListener(null);
      SpeechPlayer.getViewer().setOnChangeListener(null);
    } finally {
      super.onDestroy();
    }
  }

  @Override
  public void onResume () {
    super.onResume();
    PositionMonitor.StopReason.INVISIBLE.start();
  }

  @Override
  public void onPause () {
    try {
      PositionMonitor.StopReason.INVISIBLE.stop();
    } finally {
      super.onPause();
    }
  }
}
