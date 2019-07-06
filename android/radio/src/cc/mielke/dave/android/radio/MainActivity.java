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

  private TextView selectionTitle = null;
  private TextView selectionSubtitle = null;

  private final CurrentSelectionWatcher.OnChangeListener selectionChangeListener =
    new CurrentSelectionWatcher.OnChangeListener() {
      private String programName;
      private String scheduleName;

      private final void updateSelectionView () {
        String title;
        String subtitle;

        if (scheduleName != null) {
          title = scheduleName;
          subtitle = programName;
        } else {
          title = programName;
          if (title == null) title = getString(R.string.title_noProgram);
          subtitle = null;
        }

        updateText(selectionTitle, title);
        updateText(selectionSubtitle, subtitle);
      }

      @Override
      public void onProgramNameChange (String name) {
        programName = name;
        updateSelectionView();
      }

      @Override
      public void onScheduleNameChange (String name) {
        scheduleName = name;
        updateSelectionView();
      }
    };

  private TextView uriMetadataTitle = null;
  private TextView uriMetadataArtist = null;

  private Button uriPlayPauseButton = null;

  private SeekBar uriSeekBar = null;
  private TextView uriSeekCurrent = null;
  private TextView uriSeekRemaining = null;

  private final UriPlayerWatcher.OnChangeListener uriChangeListener =
    new UriPlayerWatcher.OnChangeListener() {
      @Override
      public void onMetadataChange (CharSequence title, CharSequence artist) {
        updateText(uriMetadataTitle, title);
        updateText(uriMetadataArtist, artist);
      }

      @Override
      public void onPlayPauseChange (Boolean isPlaying) {
        if (isPlaying == null) isPlaying = false;

        int label;
        int image;

        if (isPlaying) {
          label = R.string.action_uriPause;
          image = android.R.drawable.ic_media_pause;
        } else {
          label = R.string.action_uriPlay;
          image = android.R.drawable.ic_media_play;
        }

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
        if (milliseconds < 0) milliseconds = 0;
        uriSeekBar.setMax(milliseconds);

        boolean enabled = milliseconds > 0;
        uriSeekBar.setEnabled(enabled);
        if (!enabled) uriSeekBar.setProgress(0);
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

  private TextView speechText = null;

  private final SpeechPlayerWatcher.OnChangeListener speechChangeListener =
    new SpeechPlayerWatcher.OnChangeListener() {
      @Override
      public void onTextChange (CharSequence text) {
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
  protected void onCreate (Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(R.layout.main);
    RadioService.start();

    selectionTitle = findViewById(R.id.selection_title);
    selectionSubtitle = findViewById(R.id.selection_subtitle);

    uriMetadataTitle = findViewById(R.id.uri_metadata_title);
    uriMetadataArtist = findViewById(R.id.uri_metadata_artist);

    uriPlayPauseButton = findViewById(R.id.uri_button_PlayPause);

    uriSeekBar = findViewById(R.id.uri_seek_bar);
    uriSeekCurrent = findViewById(R.id.uri_seek_current);
    uriSeekRemaining = findViewById(R.id.uri_seek_remaining);

    uriSeekBar.setKeyProgressIncrement((int)RadioParameters.USER_SEEK_INCREMENT);
    uriSeekBar.setOnSeekBarChangeListener(uriSeekBarChangeListener);

    speechText = findViewById(R.id.speech_text);

    UriPlayer.getWatcher().setOnChangeListener(uriChangeListener);
    SpeechPlayer.getWatcher().setOnChangeListener(speechChangeListener);
    CurrentSelection.getWatcher().setOnChangeListener(selectionChangeListener);

    programSelector = new ProgramSelector(this);
  }

  @Override
  protected void onNewIntent (Intent intent) {
  }

  @Override
  protected void onDestroy () {
    try {
      UriPlayer.getWatcher().setOnChangeListener(null);
      SpeechPlayer.getWatcher().setOnChangeListener(null);
      CurrentSelection.getWatcher().setOnChangeListener(null);
    } finally {
      super.onDestroy();
    }
  }

  @Override
  protected void onResume () {
    super.onResume();
    PositionMonitor.StopReason.INVISIBLE.start();
  }

  @Override
  protected void onPause () {
    try {
      PositionMonitor.StopReason.INVISIBLE.stop();
    } finally {
      super.onPause();
    }
  }
}
