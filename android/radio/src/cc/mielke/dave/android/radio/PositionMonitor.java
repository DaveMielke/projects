package cc.mielke.dave.android.radio;

import android.util.Log;

public abstract class PositionMonitor extends AudioComponent {
  private final static String LOG_TAG = PositionMonitor.class.getName();

  private PositionMonitor () {
  }

  private static Thread monitorThread = null;
  private static int stopDepth = 0;

  private static void startMonitor () {
    synchronized (AUDIO_LOCK) {
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

  private static void stopMonitor () {
    synchronized (AUDIO_LOCK) {
      monitorThread.interrupt();
      monitorThread = null;
    }
  }

  public static enum StopReason {
    INACTIVE(true),
    INVISIBLE(true),
    PAUSE(false),
    TOUCH(false),
    ; // end of enumeration

    private boolean currentState = false;

    private final boolean setState (boolean newState, String action) {
      if (newState == currentState) return false;

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

      if ((currentState = newState)) {
        return stopDepth++ == 0;
      }

      if (stopDepth <= 0) {
        throw new IllegalStateException("stop depth underflow");
      }

      return --stopDepth == 0;
    }

    StopReason (boolean state) {
      setState(state, null);
    }

    public final void start () {
      if (setState(false, "start")) startMonitor();
    }

    public final void stop () {
      if (setState(true, "stop")) stopMonitor();
    }
  }
}
