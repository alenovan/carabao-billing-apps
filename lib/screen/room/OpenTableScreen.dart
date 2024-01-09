import 'package:carabaobillingapps/constant/data_constant.dart';
import 'package:carabaobillingapps/service/repository/RoomsRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/color_constant.dart';

class OpenTableScreen extends StatefulWidget {
  final String code;

  const OpenTableScreen({super.key, required this.code});

  @override
  State<OpenTableScreen> createState() => _OpenTableScreenState();
}
class _OpenTableScreenState extends State<OpenTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50.w,
          ),
          GestureDetector(
            onTap: () async{
              await RoomsRepoRepositoryImpl().openRooms(ConstantData.ip +
                  widget.code +
                  "on" +
                  "?key=" +
                  ConstantData.key);
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorConstant.on,
                  ),
                  color: ColorConstant.on,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              height: 50.w,
              margin: EdgeInsets.only(left: 20.w, right: 20.w),
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Center(
                child: Text(
                  "ON",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                      color: ColorConstant.white),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              RoomsRepoRepositoryImpl().openRooms(ConstantData.ip +
                  widget.code +
                  "off" +
                  "?key=" +
                  ConstantData.key);
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorConstant.off,
                  ),
                  color: ColorConstant.off,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              height: 50.w,
              margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.w),
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Center(
                child: Text(
                  "OFF",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                      color: ColorConstant.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
