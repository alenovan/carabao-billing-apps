import 'package:carabaobillingapps/constant/color_constant.dart';
import 'package:carabaobillingapps/screen/room/RoomScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant/image_constant.dart';

class MenuListCard extends StatefulWidget {
  final bool status;
  final String name;
  final String code;
  final DateTime end;

  const MenuListCard(
      {super.key,
      required this.status,
      required this.name,
      required this.end,
      required this.code});

  @override
  State<MenuListCard> createState() => _MenuListCardState();
}

class _MenuListCardState extends State<MenuListCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RoomScreen(
                    name: widget.name,
                    code: widget.code,
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
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: ColorConstant.titletext,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "1 Hour - 40 Menit lagi selesai.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 10.sp, color: ColorConstant.subtext),
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
                        style: GoogleFonts.poppins(
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
                        style: GoogleFonts.poppins(
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
