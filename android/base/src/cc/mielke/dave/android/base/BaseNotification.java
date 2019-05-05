package cc.mielke.dave.android.base;

import java.util.ArrayList;

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
  protected final int notificationIdentifier;

  private final Service notificationService;
  private final NotificationManager notificationManager;
  private final Notification.Builder notificationBuilder;

  protected final Service getService () {
    return notificationService;
  }

  protected String getChannelIdentifier () {
    return BaseApplication.getName();
  }

  protected String getChannelName () {
    return getChannelIdentifier();
  }

  protected int getLargeIcon () {
    return getService().getApplicationInfo().icon;
  }

  protected int getSmallIcon () {
    return getLargeIcon();
  }

  protected int getImportance () {
    return NotificationManager.IMPORTANCE_DEFAULT;
  }

  protected int getPriority () {
    return Notification.PRIORITY_DEFAULT;
  }

  protected int getVisibility () {
    return Notification.VISIBILITY_PRIVATE;
  }

  protected Class<? extends Activity> getActivityClass () {
    return null;
  }

  protected final PendingIntent newPendingIntent (Class<? extends Activity> activityClass) {
    Context context = getContext();
    Intent intent = new Intent(context, activityClass);

    intent.addFlags(
      Intent.FLAG_ACTIVITY_CLEAR_TASK |
      Intent.FLAG_ACTIVITY_NEW_TASK
    );

    return PendingIntent.getActivity(
      context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT
    );
  }

  private final Notification.Builder makeNotificationBuilder (Context context) {
    Notification.Builder builder;

    if (ApiTests.haveOreo) {
      String identifier = getChannelIdentifier();
      NotificationChannel channel = notificationManager.getNotificationChannel(identifier);

      if (channel == null) {
        channel = new NotificationChannel(
          identifier, getChannelName(), getImportance()
        );

        notificationManager.createNotificationChannel(channel);
      }

      builder = new Notification.Builder(context, identifier);
    } else {
      builder = new Notification.Builder(context)
        .setPriority(getPriority())
        ;
    }

    builder.setOngoing(true).setOnlyAlertOnce(true);

    {
      int icon = getLargeIcon();
      if (icon != 0) builder.setLargeIcon(BitmapFactory.decodeResource(getResources(), icon));
    }

    {
      int icon = getSmallIcon();
      if (icon != 0) builder.setSmallIcon(icon);
    }

    {
      Class<? extends Activity> activityClass = getActivityClass();
      if (activityClass != null) {
        builder.setContentIntent(newPendingIntent(activityClass))
               .setAutoCancel(true)
               ;
      }
    }

    if (ApiTests.haveJellyBeanMR1) {
      builder.setShowWhen(true);
    }

    if (ApiTests.haveLollipop) {
      builder.setCategory(Notification.CATEGORY_SERVICE);
      builder.setVisibility(getVisibility());
    }

    return builder;
  }

  private final Notification buildNotification () {
    return notificationBuilder.build();
  }

  public final void showNotification (boolean foreground) {
    synchronized (this) {
      Notification notification = buildNotification();

      if (foreground) {
        getService().startForeground(notificationIdentifier, notification);
      } else {
        notificationManager.notify(notificationIdentifier, notification);
      }
    }
  }

  public final void showNotification () {
    showNotification(false);
  }

  public final void setTitle (CharSequence text) {
    if (text == null) text = "";

    synchronized (this) {
      notificationBuilder.setContentTitle(text);
    }
  }

  public final void setText (CharSequence text) {
    if (text == null) text = "";

    synchronized (this) {
      notificationBuilder.setContentText(text);
    }
  }

  public final void setSubText (CharSequence text) {
    if (text == null) text = "";

    synchronized (this) {
      notificationBuilder.setSubText(text);
    }
  }

  private final static int actionLimit = 3;
  private int actionCount = 0;
  private ArrayList<Notification.Action> actionList = null;

  protected final Notification.Action getAction (int index) {
    synchronized (this) {
      return actionList.get(index);
    }
  }

  protected final boolean setAction (int index, Notification.Action action) {
    if (ApiTests.HAVE_Notification_Builder_setActions) {
      synchronized (this) {
        actionList.set(index, action);
        notificationBuilder.setActions(actionList.toArray(new Notification.Action[actionList.size()]));
        return true;
      }
    }

    return false;
  }

  protected final Notification.Action newAction (int icon, CharSequence label, PendingIntent intent) {
    return new Notification.Action.Builder(icon, label, intent)
             .build();
  }

  protected final Notification.Action newAction (int icon, CharSequence label, Class<? extends Activity> activityClass) {
    return newAction(icon, label, newPendingIntent(activityClass));
  }

  protected final int addAction (int icon, CharSequence label, Class<? extends Activity> activityClass) {
    PendingIntent intent = newPendingIntent(activityClass);

    synchronized (this) {
      if (actionCount == actionLimit) {
        throw new IllegalStateException("too many actions");
      }

      if (ApiTests.HAVE_Notification_Action) {
        Notification.Action action = newAction(icon, label, intent);
        notificationBuilder.addAction(action);
        actionList.add(action);
      } else {
        notificationBuilder.addAction(icon, label, intent);
      }

      return actionCount++;
    }
  }

  protected BaseNotification (Service service) {
    super();

    synchronized (IDENTIFIER_LOCK) {
      notificationIdentifier = ++uniqueIdentifier;
    }

    notificationService = service;
    notificationManager = (NotificationManager)service.getSystemService(Context.NOTIFICATION_SERVICE);
    notificationBuilder = makeNotificationBuilder(service);

    if (ApiTests.HAVE_Notification_Action) {
      actionList = new ArrayList<>();
    }
  }
}
