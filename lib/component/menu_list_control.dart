import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/color_constant.dart';
import '../constant/data_constant.dart';
import '../service/repository/RoomsRepository.dart';

class MenuListControl extends StatefulWidget {
  final String name;
  final String code;

  const MenuListControl({super.key, required this.name, required this.code});

  @override
  State<MenuListControl> createState() => _MenuListControlState();
}

class _MenuListControlState extends State<MenuListControl> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(20.w),
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
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp, color: ColorConstant.titletext),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await RoomsRepoRepositoryImpl().openRooms(
                          ConstantData.ip +
                              widget.code +
                              "on" +
                              "?key=" +
                              ConstantData.key);
                    },
                    child: Container(
                      width: 55.w,
                      decoration: BoxDecoration(
                          color: ColorConstant.on,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: 30.w,
                      child: Center(
                        child: Text(
                          "ON",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  GestureDetector(
                      onTap: () async {
                        await RoomsRepoRepositoryImpl().openRooms(
                            ConstantData.ip +
                                widget.code +
                                "off" +
                                "?key=" +
                                ConstantData.key);
                      },
                      child: Container(
                        width: 55.w,
                        decoration: BoxDecoration(
                            color: ColorConstant.off,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        height: 30.w,
                        child: Center(
                          child: Text(
                            "OFF",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp, color: Colors.white),
                          ),
                        ),
                      )),
                  SizedBox(
                    width: 5.w,
                  ),
                  Container(
                    width: 55.w,
                    decoration: BoxDecoration(
                        color: ColorConstant.primary,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 30.w,
                    child: Center(
                      child: Text(
                        "RESET",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
