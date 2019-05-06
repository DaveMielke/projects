package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class PositionMonitor extends AudioComponent {
  private final static String LOG_TAG = PositionMonitor.class.getName();

  private PositionMonitor () {
  }

  private static Thread monitorThread = null;
  private static int stopDepth = 0;

  public static enum StopReason {
    INACTIVE(true),
    INVISIBLE(true),
    PAUSE(false),
    TOUCH(false),
    ; // end of enumeration

    private boolean currentState = false;

    private final boolean set (boolean state, String action) {
      if (state == currentState) return false;

      if (RadioParameters.LOG_POSITION_MONITOR) {
        if (action != null) {
          Log.d(LOG_TAG,
            String.format(
              "%s position monitor: %s: %d",
              action, name(), stopDepth
            )
          );
        }
      }

      if ((currentState = state)) {
        return stopDepth++ == 0;
      }

      if (stopDepth <= 0) {
        throw new IllegalStateException("stop depth underflow");
      }

      return --stopDepth == 0;
    }

    public final boolean begin () {
      return set(true, "stop");
    }

    public final boolean end () {
      return set(false, "start");
    }

    StopReason (boolean state) {
      set(state, null);
    }
  }

  public static void start (StopReason reason) {
    synchronized (AUDIO_LOCK) {
      if (reason.end()) {
        monitorThread =
          new Thread("position-mnitor") {
            @Override
            public void run () {
              if (RadioParameters.LOG_POSITION_MONITOR) {
                Log.d(LOG_TAG, "position monitor started");
              }

              final UriViewer uriViewer = UriPlayer.getViewer();
              boolean stop = false;

              while (true) {
                post(
                  new Runnable() {
                    @Override
                    public void run () {
                      synchronized (AUDIO_LOCK) {
                        uriViewer.setPosition(UriPlayer.getPosition());
                      }
                    }
                  }
                );

                if (stop) break;

                try {
                  sleep(RadioParameters.POSITION_MONITOR_INTERVAL);
                } catch (InterruptedException exception) {
                  stop = true;
                }
              }

              if (RadioParameters.LOG_POSITION_MONITOR) {
                Log.d(LOG_TAG, "position monitor stopped");
              }
            }
          };

        monitorThread.start();
      }
    }
  }

  public static void stop (StopReason reason) {
    synchronized (AUDIO_LOCK) {
      if (reason.begin()) {
        monitorThread.interrupt();
        monitorThread = null;
      }
    }
  }
}
