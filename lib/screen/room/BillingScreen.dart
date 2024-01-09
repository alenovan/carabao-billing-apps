import 'package:boxicons/boxicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/color_constant.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late String selected_time = "Choose Hourse";
  late int selected_time_nunber;

  @override
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 600.w, // Adjust the height as needed
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (BuildContext context, int index) {
              // Assuming the menu items are from 1 to 12
              final int hours = index + 1;
              return ListTile(
                title: Text('$hours Hours'),
                onTap: () {
                  setState(() {
                    selected_time = '$hours Hours';
                    selected_time_nunber = hours;
                  });
                  // Handle the selected menu item
                  Navigator.pop(context); // Close the bottom sheet
                  // Add your logic here for the selected menu item
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50.w,
          ),
          InkWell(
            onTap: () {
              _showBottomSheet(context);
            },
            child: Container(
              height: 70.w,
              margin: EdgeInsets.only(left: 20.w, right: 20.w),
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
                          Icon(
                            Boxicons.bx_alarm,
                            color: ColorConstant.alarm,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hours :",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.sp,
                                    color: ColorConstant.subtext,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${selected_time}",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.sp,
                                    color: ColorConstant.titletext),
                              ),
                            ],
                          )
                        ],
                      ),
                      Icon(
                        Boxicons.bx_chevron_down,
                        color: ColorConstant.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorConstant.primary,
                  ),
                  color: ColorConstant.primary,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              height: 50.w,
              margin: EdgeInsets.all(20.w),
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Center(
                child: Text(
                  "Start",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp, color: ColorConstant.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
