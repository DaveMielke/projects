package cc.mielke.dave.android.base;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;

import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;

import android.app.Activity;
import android.app.Service;

import android.graphics.BitmapFactory;

public abstract class BaseNotification extends BaseComponent {
  private final static String LOG_TAG = BaseNotification.class.getName();

  private final static Object IDENTIFIER_LOCK = new Object();
  private static int uniqueIdentifier = 0;
  protected final Integer notificationIdentifier;

  protected BaseNotification () {
    super();

    synchronized (IDENTIFIER_LOCK) {
      notificationIdentifier = ++uniqueIdentifier;
    }
  }

  protected int getSmallIcon () {
    return 0;
  }

  protected int getLargeIcon () {
    return 0;
  }

  protected String getChannelIdentifier () {
    return BaseApplication.getName();
  }

  protected String getChannelName () {
    return getChannelIdentifier();
  }

  protected int getImportance () {
    return NotificationManager.IMPORTANCE_DEFAULT;
  }

  protected int getPriority () {
    return Notification.PRIORITY_DEFAULT;
  }

  protected int getVisibility () {
    return Notification.VISIBILITY_PUBLIC;
  }

  protected String getTitle () {
    return BaseApplication.getName();
  }

  protected Class<? extends Activity> getMainActivityClass () {
    return null;
  }

  private NotificationManager notificationManager = null;
  private Notification.Builder notificationBuilder = null;

  private final NotificationManager getManager () {
    if (notificationManager == null) {
      notificationManager = (NotificationManager)
                            getContext()
                           .getSystemService(Context.NOTIFICATION_SERVICE);
    }

    return notificationManager;
  }

  protected final PendingIntent newPendingIntent (Class<? extends Activity> activityClass) {
    Context context = getContext();
    Intent intent = new Intent(context, activityClass);

    intent.addFlags(
      Intent.FLAG_ACTIVITY_CLEAR_TASK |
      Intent.FLAG_ACTIVITY_NEW_TASK
    );

    return PendingIntent.getActivity(context, 0, intent, 0);
  }

  private final void makeBuilder () {
    Context context = getContext();

    if (ApiTests.haveOreo) {
      NotificationManager manager = getManager();
      String identifier = getChannelIdentifier();
      NotificationChannel channel = manager.getNotificationChannel(identifier);

      if (channel == null) {
        channel = new NotificationChannel(
          identifier, getChannelName(), getImportance()
        );

        manager.createNotificationChannel(channel);
      }

      notificationBuilder = new Notification.Builder(context, identifier);
    } else {
      notificationBuilder = new Notification.Builder(context)
        .setPriority(getPriority())
        ;
    }

    notificationBuilder
      .setOngoing(true)
      .setOnlyAlertOnce(true)
      ;

    {
      int icon = getSmallIcon();
      if (icon != 0) notificationBuilder.setSmallIcon(icon);
    }

    {
      int icon = getLargeIcon();

      if (icon != 0) {
        notificationBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), icon));
      }
    }

    {
      String title = getTitle();
      if (title != null) notificationBuilder.setContentTitle(title);
    }

    {
      Class<? extends Activity> activity = getMainActivityClass();

      if (activity != null) {
        notificationBuilder.setContentIntent(newPendingIntent(activity));
      }
    }

    if (ApiTests.haveJellyBeanMR1) {
      notificationBuilder.setShowWhen(true);
    }

    if (ApiTests.haveLollipop) {
      notificationBuilder.setCategory(Notification.CATEGORY_SERVICE);
      notificationBuilder.setVisibility(getVisibility());
    }
  }

  private final boolean haveBuilder () {
    return notificationBuilder != null;
  }

  private final Notification buildNotification () {
    return notificationBuilder.build();
  }

  protected final void refreshNotification () {
    getManager().notify(notificationIdentifier, buildNotification());
  }

  protected final void setPrimaryText (CharSequence text) {
    notificationBuilder.setContentText(text);
  }

  public final void updatePrimaryText (CharSequence text) {
    synchronized (notificationIdentifier) {
      if (haveBuilder()) {
        setPrimaryText(text);
        refreshNotification();
      }
    }
  }

  protected final void setSecondaryText (CharSequence text) {
    notificationBuilder.setSubText(text);
  }

  public final void updateSecondaryText (CharSequence text) {
    synchronized (notificationIdentifier) {
      if (haveBuilder()) {
        setSecondaryText(text);
        refreshNotification();
      }
    }
  }

/*
  private static boolean create (boolean refresh) {
    synchronized (notificationIdentifier) {
      if (haveBuilder()) return false;

      makeBuilder();
      setSessionState(R.string.session_stateOff, null);
      setAlertCount();

      if (refresh) refreshNotification();
      return true;
    }
  }

  public static void create () {
    create(true);
  }

  public static void create (Service service) {
    synchronized (notificationIdentifier) {
      create(false);
      service.startForeground(notificationIdentifier, buildNotification());
    }
  }
*/
}
