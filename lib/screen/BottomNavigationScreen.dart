import 'dart:async';

import 'package:boxicons/boxicons.dart';
import 'package:carabaobillingapps/component/menu_list_card.dart';
import 'package:carabaobillingapps/constant/color_constant.dart';
import 'package:carabaobillingapps/constant/image_constant.dart';
import 'package:carabaobillingapps/util/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../component/empty_table_order.dart';
import '../service/models/order/ResponseListOrdersModels.dart';
import 'menu/HistoryScreen.dart';
import 'menu/HomeScreen.dart';
import 'menu/SettingScreen.dart';

class BottomNavigationScreen extends StatefulWidget {
  final int? defaultMenuIndex;

  const BottomNavigationScreen({super.key, this.defaultMenuIndex = 0});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late int _currentIndex;
  late PageController _pageController;
  CountdownTimer? countdownTimer;
  List<NewestOrder> _activeOrders = [];
  bool _isUpdated = false; // Track the update state
  Color _fabColor = ColorConstant.primary; // Default FAB color
  Timer? _blinkTimer; // Timer for blinking effect

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.defaultMenuIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  Future<void> fetchActiveOrders() async {
    List<NewestOrder> activeOrders = await DatabaseHelper().getActiveOrders();

    // Simulate the onUpdate status based on some conditions in your logic.
    bool updateStatus = activeOrders.any((order) => order.statusRooms == 1);

    // Call setState to update the UI with the new data and set the update status
    setState(() {
      _activeOrders = activeOrders; // Store the active orders in the state
      _isUpdated = updateStatus; // Update the state with the onUpdate status
    });

    // Start or stop blinking based on the update status
    if (_isUpdated) {
      _startBlinking();
    } else {
      _stopBlinking();
      setState(() {
        _fabColor =
            ColorConstant.primary; // Reset to primary color when not blinking
      });
    }
  }

  // Start the blinking effect
  void _startBlinking() {
    _blinkTimer?.cancel(); // Cancel any previous timer
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        // Toggle between red and primary color
        _fabColor = (_fabColor == ColorConstant.primary)
            ? Colors.red
            : ColorConstant.primary;
      });
    });
  }

  // Stop the blinking effect
  void _stopBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    countdownTimer?.cancel();
    _blinkTimer
        ?.cancel(); // Cancel the blinking timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorConstant.bg,
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await fetchActiveOrders();
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: _activeOrders.isEmpty
                      ? const EmptyTableOrder()
                      : ListView.builder(
                          itemCount: _activeOrders.length,
                          itemBuilder: (context, index) {
                            var data = _activeOrders[index];
                            return MenuListCard(
                              status: data.statusRooms == 1,
                              name: data.name!,
                              idOrder: data.id.toString(),
                              code: data.code!,
                              start: data.newestOrderStartTime!,
                              end: data.newestOrderEndTime!,
                              idMeja: data.roomId.toString(),
                              type: data.type.toString(),
                              ip: data.ip!,
                              keys: data.secret!,
                              onUpdate: () async {
                                await fetchActiveOrders();
                              },
                              onCloseAutoCut: () {
                                setState(() {
                                  _isUpdated = false;
                                });
                              },
                            );
                          },
                        ),
                );
              },
            );
          },
          // Use the dynamically blinking color
          backgroundColor: _fabColor,
          child: Icon(
            Boxicons.bxs_flame,
            color: Colors.white,
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            fetchActiveOrders();
          },
          children: const [
            HomeScreen(),
            HistoryScreen(),
            SettingScreen(),
          ],
        ),
      ),
    );
  }

  // Bottom navigation bar builder
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 56.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                _navigateToPage(0);
              },
              child: Image.asset(
                _currentIndex == 0
                    ? ImageConstant.home_selected
                    : ImageConstant.home,
                width: 45.w,
                height: 45.w,
              ),
            ),
            const VerticalDivider(
              color: ColorConstant.dividermenu,
              thickness: 1.0,
              width: 20.0,
            ),
            InkWell(
              onTap: () {
                _navigateToPage(1);
              },
              child: Image.asset(
                _currentIndex == 1
                    ? ImageConstant.history
                    : ImageConstant.history_selected,
                width: 45.w,
                height: 45.w,
              ),
            ),
            const VerticalDivider(
              color: ColorConstant.dividermenu,
              thickness: 1.0,
              width: 20.0,
            ),
            InkWell(
              onTap: () {
                _navigateToPage(2);
              },
              child: Image.asset(
                _currentIndex == 2
                    ? ImageConstant.setting_selected
                    : ImageConstant.setting,
                width: 45.w,
                height: 45.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation function to handle page change
  void _navigateToPage(int index) {
    fetchActiveOrders();
    _pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  // Countdown timer setup and handling
  void _setupCountdownTimer() {
    DateTime endTime = DateTime.now().add(const Duration(minutes: 5));

    countdownTimer = CountdownTimer(
      key: "timer1",
      endTime: endTime,
      onTick: (remainingTime) {
        print(
            'Remaining time: ${remainingTime.inMinutes}:${remainingTime.inSeconds % 60}');
      },
      onCountdownFinish: () {
        print("Countdown finished!");
        _showCountdownFinishedDialog();
      },
      onStart: () {
        print("Countdown started!");
      },
    );

    countdownTimer?.start();
  }

  // Show a dialog when the countdown finishes
  void _showCountdownFinishedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Countdown Finished'),
          content: const Text('The countdown timer has finished.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Countdown Timer Class
class CountdownTimer {
  final String key;
  final DateTime endTime;
  final Function(Duration) onTick;
  final Function() onCountdownFinish;
  final Function() onStart;
  late Timer _timer;

  CountdownTimer({
    required this.key,
    required this.endTime,
    required this.onTick,
    required this.onCountdownFinish,
    required this.onStart,
  });

  void start() {
    final Duration countdownDuration = endTime.difference(DateTime.now());
    onStart();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final Duration remainingTime = endTime.difference(DateTime.now());
      if (remainingTime.inSeconds <= 0) {
        _timer.cancel();
        onCountdownFinish();
      } else {
        onTick(remainingTime);
      }
    });
  }

  void cancel() {
    _timer.cancel();
  }
}
