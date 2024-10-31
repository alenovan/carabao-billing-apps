import 'dart:async';

import 'package:carabaobillingapps/constant/color_constant.dart';
import 'package:carabaobillingapps/screen/room/RoomScreen.dart';
import 'package:carabaobillingapps/util/TimerService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant/data_constant.dart';
import '../constant/image_constant.dart';
import '../helper/BottomSheetFeedback.dart';
import '../helper/shared_preference.dart';

class MenuListCard extends StatefulWidget {
  final bool status;
  final String name;
  final String idMeja;
  final String? idOrder;
  final String code;
  final String end;
  final String start;
  final String type;
  final String ip;
  final String keys;
  final Function() onUpdate;
  final Function() onCloseAutoCut;

  MenuListCard({
    required this.status,
    required this.name,
    required this.end,
    required this.code,
    required this.idMeja,
    required this.type,
    required this.start,
    this.idOrder,
    required this.ip,
    required this.keys,
    required this.onUpdate,
    required this.onCloseAutoCut,
  });

  @override
  State<MenuListCard> createState() => _MenuListCardState();
}

class _MenuListCardState extends State<MenuListCard> {
  Timer? _displayTimer;
  String? _currentTimerId;
  bool isOrange = true;
  Color _currentBackgroundColor = ColorConstant.white;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(MenuListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if relevant properties changed
    if (oldWidget.status != widget.status ||
        oldWidget.idOrder != widget.idOrder ||
        oldWidget.type != widget.type) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _cleanupTimer();
    super.dispose();
  }

  void _cleanupTimer() {
    _displayTimer?.cancel();
    _displayTimer = null;
    _currentTimerId = null;
  }

  void _resetTimer() {
    _cleanupTimer();
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    // Only start timer if status is true and we have an order ID
    if (widget.status && widget.idOrder != null) {
      // Generate unique timer ID combining order ID and type
      final newTimerId = '${widget.idOrder}-${widget.type}';

      // Only start new timer if ID changed
      if (_currentTimerId != newTimerId) {
        _cleanupTimer();
        _currentTimerId = newTimerId;
        startDisplayTimer();
      }
    } else {
      _cleanupTimer();
      // Reset background color when timer stops
      setState(() {
        _currentBackgroundColor = ColorConstant.white;
      });
    }
  }

  void startDisplayTimer() {
    print("start display timer: " + (_currentTimerId ?? "no id"));
    // Store the timer ID we're creating
    final timerIdAtStart = _currentTimerId;

    _displayTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      // First validate widget is still mounted and timer is current
      if (!mounted || _currentTimerId != timerIdAtStart) {
        timer.cancel();
        _cleanupTimer(); // Ensure full cleanup
        return;
      }

      try {
        // Validate widget state hasn't changed
        if (!widget.status || widget.idOrder == null) {
          timer.cancel();
          _cleanupTimer(); // Ensure full cleanup
          setState(() {
            _currentBackgroundColor = ColorConstant.white; // Reset color
          });
          return;
        }

        // Validate timer service state
        final timeInfo =
            TimerService.instance.getRemainingTime(widget.idOrder!);
        if (timeInfo == null) {
          timer.cancel();
          _cleanupTimer(); // Ensure full cleanup
          setState(() {
            _currentBackgroundColor = ColorConstant.white; // Reset color
          });
          return;
        }

        // Validate order type hasn't changed
        final orderType = TimerService.instance.getOrderType(widget.idOrder!);
        if (orderType != widget.type) {
          timer.cancel();
          _cleanupTimer(); // Ensure full cleanup
          setState(() {
            _currentBackgroundColor = ColorConstant.white; // Reset color
          });
          return;
        }

        // Only do setState if mounted and timer is still valid
        if (mounted && _currentTimerId == timerIdAtStart) {
          setState(() {
            // Update background color
            if (widget.type == "OPEN-BILLING") {
              if (timeInfo.inMinutes <= 1 && timeInfo.inSeconds > 0) {
                _currentBackgroundColor =
                    isOrange ? Colors.orange : Colors.white;
                isOrange = !isOrange;
              } else {
                _currentBackgroundColor = ColorConstant.white;
              }
            }
          });
        }
      } catch (e) {
        print('Error in display timer: $e');
        timer.cancel();
        _cleanupTimer(); // Ensure cleanup even if error occurs
        if (mounted) {
          setState(() {
            _currentBackgroundColor = ColorConstant.white; // Reset color
          });
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Widget _buildStatusText() {
    if (widget.status == 0 || widget.idOrder == null) {
      return Text(!widget.status ? "--/--" : widget.type,
          style: _subTextStyle());
    }

    final timeInfo = TimerService.instance.getRemainingTime(widget.idOrder!);
    print(timeInfo);
    if (timeInfo == null) {
      return Text(widget.type, style: _subTextStyle());
    }

    if (widget.type == "OPEN-BILLING") {
      if (timeInfo.inSeconds <= 0) {
        return Text(
          "Habis Matikan Lampu",
          style: _subTextStyle().copyWith(color: Colors.red),
        );
      }
      return Text(
        "${_formatDuration(timeInfo)} Lagi Habis",
        style: _subTextStyle(),
      );
    } else if (widget.type == "OPEN-TABLE") {
      return Text(
        "Open Table - ${_formatDuration(timeInfo)}",
        style: _subTextStyle(),
      );
    }

    return SizedBox();
  }

  TextStyle _subTextStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 10.sp,
      color: ColorConstant.subtext,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: _currentBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2.0,
              spreadRadius: 1.0,
              offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.all(15.w),
      child: InkWell(
        onTap: () async {
          var timerSetting = await getSF(ConstantData.is_timer);
          if (timerSetting == "1" || timerSetting == true) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => RoomScreen(meja_id: widget.idMeja)));
          } else {
            BottomSheetFeedback.showError(context, "Mohon Maaf",
                "Akun anda tidak di izinkan untuk menjalankan billing");
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(ImageConstant.xinjue, width: 50.w),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    _buildStatusText(),
                  ],
                ),
              ],
            ),
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      width: widget.status ? 75.w : 55.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: widget.status ? ColorConstant.error : ColorConstant.success,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          widget.status ? "In Use" : "Ready",
          style:
              GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: Colors.white),
        ),
      ),
    );
  }
}
