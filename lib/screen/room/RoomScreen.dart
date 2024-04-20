import 'package:carabaobillingapps/screen/room/OpenTableScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/color_constant.dart';
import 'BillingScreen.dart';

class RoomScreen extends StatefulWidget {
  final String name;
  final String id_meja;
  final String? id_order;
  final String code;
  final bool status;
  final String type;
  final String ip;
  final String keys;

  const RoomScreen(
      {super.key,
      required this.name,
      required this.code,
      required this.id_meja,
      required this.status,
      this.id_order,
      required this.type,
      required this.ip,
      required this.keys});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20.w),
            height: 50.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.type == "OPEN-TABLE" ||
                    widget.type == "null" ||
                    !widget.status)
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      _navigateToPage(0);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentIndex == 0
                                ? ColorConstant.primary
                                : ColorConstant.subtext,
                          ),
                          color: _currentIndex == 0
                              ? ColorConstant.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      height: 50.w,
                      width: 100.w,
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: Center(
                        child: Text(
                          "Open Table",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              color: _currentIndex == 0
                                  ? ColorConstant.white
                                  : ColorConstant.subtext),
                        ),
                      ),
                    ),
                  )),
                SizedBox(
                  width: 10.w,
                ),
                if (widget.type == "OPEN-BILLING" ||
                    widget.type == "null" ||
                    !widget.status)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _navigateToPage(1);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: _currentIndex == 1
                                  ? ColorConstant.primary
                                  : ColorConstant.subtext,
                            ),
                            color: _currentIndex == 1
                                ? ColorConstant.primary
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        height: 50.w,
                        padding: EdgeInsets.only(left: 20.w, right: 20.w),
                        child: Center(
                          child: Text(
                            "Billing",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: _currentIndex == 1
                                    ? ColorConstant.white
                                    : ColorConstant.subtext),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                if (widget.type == "OPEN-TABLE" ||
                    widget.type == "null" ||
                    !widget.status)
                  OpenTableScreen(
                    id_order: widget.id_order,
                    id_meja: widget.id_meja,
                    code: widget.code,
                    status: widget.status,
                    ip: widget.ip,
                    keys: widget.keys,
                  ),
                if (widget.type == "OPEN-BILLING" ||
                    widget.type == "null" ||
                    !widget.status)
                  BillingScreen(
                    id_meja: widget.id_meja,
                    code: widget.code,
                    id_order: widget.id_order,
                    status: widget.status,
                    ip: widget.ip,
                    keys: widget.keys,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
