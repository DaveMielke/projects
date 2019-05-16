package cc.mielke.dave.android.base;

import android.content.Context;

import android.net.Uri;
import android.media.AudioAttributes;

public abstract class StreamPlayer {
  protected final Context playerContext;

  public StreamPlayer (Context context) {
    playerContext = context;
  }

  protected boolean getLogEvents () {
    return false;
  }

  protected boolean onPlayerStart () {
    return true;
  }

  protected void onPlayerFinished () {
  }

  public abstract boolean setSource (Uri uri);
  public abstract void setAudioAttributes (AudioAttributes attributes);

  public abstract void start ();
  public abstract void stop ();

  public abstract boolean isPlaying ();
  public abstract void suspend ();
  public abstract void resume ();

  public abstract int getDuration ();
  public abstract int getPosition ();
  public abstract void setPosition (int milliseconds);

  public static StreamPlayer newAndroidMediaPlayer (Context context) {
    return new AndroidMediaPlayer(context);
  }
}
