import 'dart:async';

import 'package:carabaobillingapps/constant/color_constant.dart';
import 'package:carabaobillingapps/screen/room/RoomScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant/image_constant.dart';
import '../helper/global_helper.dart';

class MenuListCard extends StatefulWidget {
  final bool status;
  final String name;
  final String id_meja;
  final String? id_order;
  final String code;
  final String end;
  final String start;
  final String type;

  const MenuListCard(
      {super.key,
      required this.status,
      required this.name,
      required this.end,
      required this.code,
      required this.id_meja,
      required this.type,
      required this.start,
      this.id_order});

  @override
  State<MenuListCard> createState() => _MenuListCardState();
}

class _MenuListCardState extends State<MenuListCard> {
  Duration _remainingTime = Duration(seconds: 0);
  late DateTime? _startTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    if (widget.type == "OPEN-BILLING" && widget.end != "No orders") {
      // Calculate the remaining time for OPEN-BILLING
      DateTime endTime = DateTime.parse(widget.end);
      Duration difference = endTime.difference(DateTime.parse(widget.start));
      _remainingTime = Duration(seconds: difference.inSeconds);

      // Start a timer to update the countdown every second
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime!.inSeconds > 0) {
          switchLamp(widget.code, true);
          setState(() {
            _remainingTime = _remainingTime! - Duration(seconds: 1);
          });
        } else {
          // Countdown has reached zero, you may want to handle this case
          timer.cancel();
          switchLamp(widget.code, false);
        }
      });
    } else if (widget.type == "OPEN-TABLE") {
      // For OPEN-TABLE, use count-up behavior
      _startTime = DateTime.parse(widget.start);
      switchLamp(widget.code, true);
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _remainingTime = DateTime.now().difference(_startTime!);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RoomScreen(
                    id_order: widget.id_order,
                    status: widget.status,
                    name: widget.name,
                    code: widget.code,
                    id_meja: widget.id_meja,
                  )),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8.w),
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: ColorConstant.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      ImageConstant.boxicons,
                      width: 50.w,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name ?? "",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: ColorConstant.titletext,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (widget.type == "OPEN-BILLING" &&
                            widget.end != "No orders" &&
                            widget.status &&
                            _remainingTime != null)
                          Text(
                            _remainingTime != null
                                ? formatDuration(_remainingTime!) +
                                    " Lagi Selesai"
                                : "N/A",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.sp,
                              color: ColorConstant.subtext,
                            ),
                          ),
                        if (widget.type == "OPEN-TABLE" &&
                            widget.status &&
                            _startTime != null &&
                            _remainingTime != null)
                          Text(
                            _remainingTime != null
                                ? (widget.type == "OPEN-TABLE"
                                        ? "Open Table"
                                        : "") +
                                    " - " +
                                    formatDuration(_remainingTime!)
                                : "N/A",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.sp,
                              color: ColorConstant.subtext,
                            ),
                          ),
                        if (!widget.status)
                          Text(
                            "Available",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.sp,
                              color: ColorConstant.subtext,
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                if (widget.status)
                  Container(
                    width: 55.w,
                    decoration: BoxDecoration(
                        color: ColorConstant.success,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    height: 30.w,
                    child: Center(
                      child: Text(
                        "Ready",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp, color: Colors.white),
                      ),
                    ),
                  ),
                if (!widget.status)
                  Container(
                    width: 75.w,
                    decoration: BoxDecoration(
                        color: ColorConstant.error,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    height: 30.w,
                    child: Center(
                      child: Text(
                        "Not Ready",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp, color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
