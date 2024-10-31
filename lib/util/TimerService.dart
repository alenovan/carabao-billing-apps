import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/models/order/ResponseListOrdersModels.dart';
import '../util/DatabaseHelper.dart';
import '../helper/global_helper.dart';

class OrderEvent {
  final String type;
  final NewestOrder order;

  OrderEvent(this.type, this.order);
}

class TimerService {
  static final TimerService _instance = TimerService._internal();
  static TimerService get instance => _instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _orderEventController = StreamController<OrderEvent>.broadcast();
  Stream<OrderEvent> get orderEvents => _orderEventController.stream;

  final Map<String, Timer> _timers = {};
  final Map<String, DateTime> _endTimes = {};
  final Map<String, String> _orderTypes = {};
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _log(String message, {String? error}) {
    final timestamp = DateTime.now().toString().split('.')[0];
  }

  TimerService._internal() {
    _log('TimerService initialized');
  }

  void _logTimerState() {
    _log('Current timer state:');
    _log('Active timers: ${_timers.length}');
    _log('End times tracked: ${_endTimes.length}');
    _log('Order types tracked: ${_orderTypes.length}');

    final allTrackedIds = {
      ..._timers.keys,
      ..._endTimes.keys,
      ..._orderTypes.keys
    };
    for (final orderId in allTrackedIds) {
      _log('Order #$orderId state:');
      _log('  Has timer: ${_timers.containsKey(orderId)}');
      _log('  Has end time: ${_endTimes.containsKey(orderId)}');
      _log('  Order type: ${_orderTypes[orderId]}');
    }
  }

  Future<void> startTimer() async {
    _log('Starting TimerService');
    stopAllTimers();

    try {
      List<NewestOrder> orders = await _dbHelper.getOrders();
      _log('Retrieved ${orders.length} orders from database');

      for (var order in orders) {
        if (order.statusOrder == 'START') {
          _log('Scheduling timer for order ${order.id} (${order.type})');
          scheduleOrderTimer(order);
        }
      }
    } catch (e, stackTrace) {
      _log('Error starting timers', error: e.toString());
      dev.log(stackTrace.toString(), name: 'TimerService');
    }

    _logTimerState();
  }

  void scheduleOrderTimer(NewestOrder order) {
    final orderId = order.id.toString();
    _log('Scheduling timer for Order #$orderId (${order.type})');

    if (_timers[orderId] != null) {
      _log('Cancelling existing timer for Order #$orderId');
      _timers[orderId]?.cancel();
    }

    _orderTypes[orderId] = order.type ?? "";

    if (order.type == "OPEN-BILLING") {
      _log('Setting up billing timer for Order #$orderId');
      _scheduleBillingTimer(order);
    } else if (order.type == "OPEN-TABLE") {
      _log('Setting up table timer for Order #$orderId');
      _scheduleTableTimer(order);
    }

    _logTimerState();
  }

  void _scheduleBillingTimer(NewestOrder order) {
    final orderId = order.id.toString();

    if (order.newestOrderEndTime == null) {
      _log('Error: No end time for billing Order #${order.id}');
      return;
    }

    final endTime = DateTime.parse(order.newestOrderEndTime!);
    _endTimes[orderId] = endTime;

    final now = DateTime.now();
    final lastMinuteWarning = endTime.subtract(Duration(minutes: 1));

    _log('''
Scheduling billing timer:
Order #$orderId
End Time: $endTime
Current Time: $now
Warning Time: $lastMinuteWarning
''');

    if (now.isAfter(endTime)) {
      _log('Order #$orderId has already expired, handling expiry');
      handleOrderExpiry(order);
      return;
    }

    if (now.isAfter(lastMinuteWarning)) {
      _log('Order #$orderId is in last minute, scheduling immediate expiry');
      _scheduleExpiryTimer(order);
    } else {
      final timeToWarning = lastMinuteWarning.difference(now);
      _log(
          'Setting warning timer for Order #$orderId (${timeToWarning.inMinutes} minutes)');

      _timers[orderId] = Timer(timeToWarning, () async {
        _log('Warning timer triggered for Order #$orderId');

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await _notificationsPlugin.show(
          int.parse(orderId),
          'Time Warning',
          'Order ${order.name} has 1 minute remaining',
          platformChannelSpecifics,
        );

        _scheduleExpiryTimer(order);
      });
    }
  }

  void _scheduleTableTimer(NewestOrder order) {
    final orderId = order.id.toString();

    if (order.newestOrderStartTime == null) {
      _log('Error: No start time for table Order #${order.id}');
      return;
    }

    final startTime = DateTime.parse(order.newestOrderStartTime!);
    _endTimes[orderId] = startTime;
    _log('Table timer scheduled for Order #$orderId starting at $startTime');
  }

  void _scheduleExpiryTimer(NewestOrder order) {
    final orderId = order.id.toString();
    final endTime = _endTimes[orderId];

    if (endTime == null) {
      _log(
          'Error: No end time found for Order #$orderId during expiry scheduling');
      return;
    }

    final timeToExpiry = endTime.difference(DateTime.now());
    _log(
        'Scheduling expiry timer for Order #$orderId (${timeToExpiry.inSeconds} seconds remaining)');

    _timers[orderId] = Timer(timeToExpiry, () {
      _log('Expiry timer triggered for Order #$orderId');
      handleOrderExpiry(order);
    });
  }

  Future<void> handleOrderExpiry(NewestOrder order) async {
    final orderId = order.id.toString();
    _log('Handling expiry for Order #$orderId');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      order.id ?? 0,
      'Order Expired',
      'Order ${order.name} has expired',
      platformChannelSpecifics,
    );

    if (order.isMultipleChannel == 1 && order.multipleChannel != null) {
      _log('Processing multiple channel expiry for Order #$orderId');
      List<dynamic> multipleChannelList = jsonDecode(order.multipleChannel!);
      for (var channel in multipleChannelList) {
        _log('Switching off lamp for channel $channel');
        switchLamp(
          ip: order.ip ?? "",
          key: order.secret ?? "",
          code: channel,
          id_order: orderId,
          status: false,
        );
      }
    } else {
      _log('Switching off single lamp for Order #$orderId');
      switchLamp(
        ip: order.ip ?? "",
        key: order.secret ?? "",
        code: order.code ?? "",
        id_order: orderId,
        status: false,
      );
    }

    final autoCut = await _getAutoCutSetting();
    if (autoCut) {
      _log('Auto-cut enabled, triggering for Order #$orderId');
      _orderEventController.add(OrderEvent('AUTO_CUT', order));
    }

    cleanupTimer(orderId);
  }

  Future<bool> _getAutoCutSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final autoCut = prefs.getBool('auto_cut') ?? false;
    _log('Auto-cut setting: $autoCut');
    return autoCut;
  }

  Duration? getRemainingTime(String orderId) {
    final endTime = _endTimes[orderId];
    final orderType = _orderTypes[orderId];

    if (endTime == null || orderType == null) {
      _log('Unable to get remaining time for Order #$orderId - missing data');
      return null;
    }

    final remaining = orderType == "OPEN-BILLING"
        ? endTime.difference(DateTime.now())
        : DateTime.now().difference(endTime);

    _log(
        'Remaining time for Order #$orderId: ${remaining.inMinutes}m ${remaining.inSeconds % 60}s');
    return remaining;
  }

  String? getOrderType(String orderId) {
    final type = _orderTypes[orderId];
    _log('Getting order type for #$orderId: $type');
    return type;
  }

  bool isInLastMinute(String orderId) {
    final endTime = _endTimes[orderId];
    final orderType = _orderTypes[orderId];

    if (endTime == null || orderType != "OPEN-BILLING") return false;

    final remaining = endTime.difference(DateTime.now());
    final isLast = remaining.inMinutes == 0 && remaining.inSeconds > 0;
    _log('Checking last minute for Order #$orderId: $isLast');
    return isLast;
  }

  void cancelTimer(String orderId) {
    _log('Manually cancelling timer for Order #$orderId');
    cleanupTimer(orderId);
  }

  void cleanupTimer(String orderId) {
    _log('Cleaning up timer for Order #$orderId');

    // Cancel timer if it exists
    if (_timers.containsKey(orderId)) {
      _timers[orderId]?.cancel();
      _timers.remove(orderId);
      _log('Timer cancelled and removed for Order #$orderId');
    }

    // Remove all associated data
    _endTimes.remove(orderId);
    _orderTypes.remove(orderId);

    _log('Cleanup completed for Order #$orderId');
  }

  void stopAllTimers() {
    _log('Stopping all timers');

    // Cancel all active timers
    _timers.forEach((orderId, timer) {
      _log('Cancelling timer for Order #$orderId');
      timer.cancel();
    });

    // Clear all state
    _timers.clear();
    _endTimes.clear();
    _orderTypes.clear();

    _log('All timers and state cleared');
  }

  bool hasActiveTimer(String orderId) {
    final hasTimer = _timers.containsKey(orderId);
    _log('Checking active timer for Order #$orderId: $hasTimer');
    return hasTimer;
  }

  Future<void> refreshTimers(List<NewestOrder> orders) async {
    _log('Refreshing timers with ${orders.length} orders');
    final activeOrders =
        orders.where((order) => order.statusOrder == "START").toList();
    _log('Found ${activeOrders.length} active orders');

    // If there are no active orders, stop all timers
    if (activeOrders.isEmpty) {
      _log('No active orders found - stopping all timers');
      stopAllTimers();
      return;
    }

    // Create a set of active order IDs for efficient lookup
    final activeOrderIds =
        activeOrders.map((order) => order.id.toString()).toSet();
    _log('Active order IDs: ${activeOrderIds.join(", ")}');

    // Find all currently tracked orders that are no longer active
    final trackedOrderIds = {
      ..._timers.keys,
      ..._endTimes.keys,
      ..._orderTypes.keys
    };
    _log('Currently tracked order IDs: ${trackedOrderIds.join(", ")}');

    // Remove any tracked orders that aren't in the active set
    for (final orderId in trackedOrderIds) {
      if (!activeOrderIds.contains(orderId)) {
        _log('Removing inactive order #$orderId from tracking');
        cleanupTimer(orderId);
      }
    }

    // Verify cleanup
    if (_timers.keys.any((id) => !activeOrderIds.contains(id)) ||
        _endTimes.keys.any((id) => !activeOrderIds.contains(id)) ||
        _orderTypes.keys.any((id) => !activeOrderIds.contains(id))) {
      _log('WARNING: Cleanup verification failed - forcing complete cleanup');
      stopAllTimers();
    }

    // Update or create timers only for active orders
    for (var order in activeOrders) {
      final orderId = order.id.toString();
      final existingEndTime = _endTimes[orderId];

      try {
        if (order.type == "OPEN-BILLING") {
          if (order.newestOrderEndTime == null) {
            _log('Error: Missing end time for billing Order #$orderId');
            continue;
          }

          final newEndTime = DateTime.parse(order.newestOrderEndTime!);
          if (existingEndTime == null || existingEndTime != newEndTime) {
            _log('Scheduling billing timer for Order #$orderId');
            // Ensure any existing timer is cleaned up first
            cleanupTimer(orderId);
            scheduleOrderTimer(order);
          }
        } else if (order.type == "OPEN-TABLE") {
          if (order.newestOrderStartTime == null) {
            _log('Error: Missing start time for table Order #$orderId');
            continue;
          }

          final startTime = DateTime.parse(order.newestOrderStartTime!);
          if (existingEndTime == null || existingEndTime != startTime) {
            _log('Scheduling table timer for Order #$orderId');
            // Ensure any existing timer is cleaned up first
            cleanupTimer(orderId);
            scheduleOrderTimer(order);
          }
        }
      } catch (e) {
        _log('Error processing Order #$orderId: $e');
        cleanupTimer(orderId);
      }
    }

    // Final verification
    _log('Verifying final timer state...');
    final finalTrackedIds = {
      ..._timers.keys,
      ..._endTimes.keys,
      ..._orderTypes.keys
    };
    if (!finalTrackedIds.every((id) => activeOrderIds.contains(id))) {
      _log('ERROR: Final verification failed - unexpected timers present');
      stopAllTimers();
    } else {
      _log('Timer refresh completed successfully');
    }

    _logTimerState();
  }

  @override
  void dispose() {
    _log('Disposing TimerService');
    _orderEventController.close();
    stopAllTimers();
  }
}
