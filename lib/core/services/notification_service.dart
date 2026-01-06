// lib/core/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int checkInSuccessId = 1;
  static const int checkOutSuccessId = 2;
  static const int checkInReminderId = 10;
  static const int checkOutReminderId = 11;

  // Storage keys
  static const String _enabledKey = 'notifications_enabled';
  static const String _checkInEnabledKey = 'checkin_reminder_enabled';
  static const String _checkOutEnabledKey = 'checkout_reminder_enabled';
  static const String _checkInTimeKey = 'checkin_reminder_time';
  static const String _checkOutTimeKey = 'checkout_reminder_time';

  // ============== INITIALIZATION ==============
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // ============== SETTINGS STORAGE ==============

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    if (!enabled) await cancelAll();
  }

  Future<bool> isCheckInReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_checkInEnabledKey) ?? true;
  }

  Future<void> setCheckInReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_checkInEnabledKey, enabled);
  }

  Future<bool> isCheckOutReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_checkOutEnabledKey) ?? true;
  }

  Future<void> setCheckOutReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_checkOutEnabledKey, enabled);
  }

  Future<TimeOfDay> getCheckInTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_checkInTimeKey);
    if (timeStr != null) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  Future<void> setCheckInTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkInTimeKey, '${time.hour}:${time.minute}');
  }

  Future<TimeOfDay> getCheckOutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_checkOutTimeKey);
    if (timeStr != null) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return const TimeOfDay(hour: 17, minute: 30);
  }

  Future<void> setCheckOutTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkOutTimeKey, '${time.hour}:${time.minute}');
  }

  // ============== NOTIFICATION DETAILS ==============
  NotificationDetails _getNotificationDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  // ============== SHOW NOTIFICATIONS ==============

  Future<void> showCheckInSuccess({
    required String time,
    String? employeeName,
  }) async {
    if (!await isNotificationsEnabled()) return;

    await _notifications.show(
      checkInSuccessId,
      '✅ Check-in thành công!',
      '${employeeName ?? 'Bạn'} đã check-in lúc $time. Chúc bạn ngày làm việc hiệu quả!',
      _getNotificationDetails(
        channelId: 'attendance_channel',
        channelName: 'Chấm công',
      ),
      payload: 'check_in',
    );
  }

  Future<void> showCheckOutSuccess({
    required String time,
    String? totalHours,
    String? employeeName,
  }) async {
    if (!await isNotificationsEnabled()) return;

    final hoursText = totalHours != null ? ' - Tổng: $totalHours' : '';

    await _notifications.show(
      checkOutSuccessId,
      '🏠 Check-out thành công!',
      '${employeeName ?? 'Bạn'} đã check-out lúc $time$hoursText. Nghỉ ngơi nhé!',
      _getNotificationDetails(
        channelId: 'attendance_channel',
        channelName: 'Chấm công',
      ),
      payload: 'check_out',
    );
  }

  // ============== SCHEDULED NOTIFICATIONS ==============

  Future<void> scheduleCheckInReminder({
    required int hour,
    required int minute,
  }) async {
    if (!await isNotificationsEnabled()) return;

    await _notifications.zonedSchedule(
      checkInReminderId,
      '⏰ Nhắc nhở Check-in',
      'Đã đến giờ làm việc! Đừng quên check-in nhé.',
      _nextInstanceOfTime(hour, minute),
      _getNotificationDetails(
        channelId: 'reminder_channel',
        channelName: 'Nhắc nhở',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'reminder_check_in',
    );

    await setCheckInTime(TimeOfDay(hour: hour, minute: minute));
    await setCheckInReminderEnabled(true);
  }

  Future<void> scheduleCheckOutReminder({
    required int hour,
    required int minute,
  }) async {
    if (!await isNotificationsEnabled()) return;

    await _notifications.zonedSchedule(
      checkOutReminderId,
      '⏰ Nhắc nhở Check-out',
      'Đã đến giờ tan làm! Đừng quên check-out nhé.',
      _nextInstanceOfTime(hour, minute),
      _getNotificationDetails(
        channelId: 'reminder_channel',
        channelName: 'Nhắc nhở',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'reminder_check_out',
    );

    await setCheckOutTime(TimeOfDay(hour: hour, minute: minute));
    await setCheckOutReminderEnabled(true);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // ============== CANCEL NOTIFICATIONS ==============

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelCheckInReminder() async {
    await cancel(checkInReminderId);
    await setCheckInReminderEnabled(false);
  }

  Future<void> cancelCheckOutReminder() async {
    await cancel(checkOutReminderId);
    await setCheckOutReminderEnabled(false);
  }
}