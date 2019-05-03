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

  protected abstract int getSmallIcon ();
  protected abstract int getLargeIcon ();

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

  protected Class<? extends Activity> getMainActivityClass () {
    return null;
  }

  private final Service notificationService;
  private final NotificationManager notificationManager;
  private final Notification.Builder notificationBuilder;

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
      int icon = getSmallIcon();
      if (icon != 0) builder.setSmallIcon(icon);
    }

    {
      int icon = getLargeIcon();
      if (icon != 0) builder.setLargeIcon(BitmapFactory.decodeResource(getResources(), icon));
    }

    {
      Class<? extends Activity> activity = getMainActivityClass();
      if (activity != null) {
        builder.setContentIntent(newPendingIntent(activity))
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

  private final static Object IDENTIFIER_LOCK = new Object();
  private static int uniqueIdentifier = 0;
  protected final int notificationIdentifier;

  protected BaseNotification (Service service) {
    super();

    synchronized (IDENTIFIER_LOCK) {
      notificationIdentifier = ++uniqueIdentifier;
    }

    notificationService = service;
    notificationManager = (NotificationManager)service.getSystemService(Context.NOTIFICATION_SERVICE);
    notificationBuilder = makeNotificationBuilder(service);
  }

  private final Notification build () {
    return notificationBuilder.build();
  }

  public final void show (boolean foreground) {
    synchronized (this) {
      Notification notification = build();

      if (foreground) {
        notificationService.startForeground(notificationIdentifier, notification);
      } else {
        notificationManager.notify(notificationIdentifier, notification);
      }
    }
  }

  public final void show () {
    show(false);
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
}
