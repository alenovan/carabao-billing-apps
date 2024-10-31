import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constant/color_constant.dart';

class EmptyTableOrder extends StatelessWidget {
  const EmptyTableOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant_outlined,
            size: 48.w,
            color: ColorConstant.subtext,
          ),
          SizedBox(height: 12.w),
          Text(
            "Tidak ada order aktif",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ColorConstant.titletext,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            "Semua meja sedang dalam kondisi ready",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: ColorConstant.subtext,
            ),
          ),
        ],
      ),
    );
  }
}
