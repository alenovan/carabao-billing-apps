import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/color_constant.dart';
import '../helper/global_helper.dart';
import 'loading_dialog.dart';

class MenuListControl extends StatefulWidget {
  final String name;
  final String code;
  final String ip;
  final String? position;
  final String keys;
  final int isMuiltiple;
  final String multipleChannel;

  const MenuListControl(
      {super.key,
      required this.name,
      required this.code,
      required this.ip,
      required this.keys,
      required this.isMuiltiple,
      required this.multipleChannel,
      this.position});

  @override
  State<MenuListControl> createState() => _MenuListControlState();
}

class _MenuListControlState extends State<MenuListControl> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(20.w, 8, 20, 8),
        decoration: BoxDecoration(
          color: ColorConstant.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(15.w),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.name,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp, color: ColorConstant.titletext),
                ),
                Text(
                  '${widget.ip.replaceAll("http://", "").replaceAll("/", "")} | ${widget.position ?? "-"}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.sp, color: ColorConstant.titletext),
                ),
              ]),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      LoadingDialog.show(context, "Mohon tunggu");
                      if (widget.isMuiltiple == 1) {
                        List<dynamic> multipleChannelList =
                            jsonDecode(widget.multipleChannel);
                        for (var e in multipleChannelList) {
                          switchLamp(
                            ip: widget.ip,
                            key: widget.keys,
                            code: e,
                            id_order: "0",
                            status: true,
                          );
                        }
                      } else {
                        switchLamp(
                            ip: widget.ip,
                            key: widget.keys,
                            code: widget.code,
                            id_order: "0",
                            status: true);
                      }
                      await Future.delayed(const Duration(seconds: 2));
                      popScreen(context);
                    },
                    child: Container(
                      width: 55.w,
                      decoration: const BoxDecoration(
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
                        LoadingDialog.show(context, "Mohon tunggu");
                        if (widget.isMuiltiple == 1) {
                          List<dynamic> multipleChannelList =
                              jsonDecode(widget.multipleChannel);
                          for (var e in multipleChannelList) {
                            switchLamp(
                              ip: widget.ip,
                              key: widget.keys,
                              code: e,
                              id_order: "0",
                              status: false,
                            );
                          }
                        } else {
                          switchLamp(
                              id_order: "0",
                              ip: widget.ip,
                              key: widget.keys,
                              code: widget.code,
                              status: false);
                        }
                        await Future.delayed(const Duration(seconds: 2));
                        popScreen(context);
                      },
                      child: Container(
                        width: 55.w,
                        decoration: const BoxDecoration(
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
                  GestureDetector(
                      onTap: () async {
                        LoadingDialog.show(context, "Mohon tunggu");
                        if (widget.isMuiltiple == 1) {
                          List<dynamic> multipleChannelList =
                              jsonDecode(widget.multipleChannel);
                          multipleChannelList.forEach((e) async {
                            switchLamp(
                                ip: widget.ip,
                                key: widget.keys,
                                id_order: "0",
                                code: e,
                                status: true);
                            await Future.delayed(const Duration(seconds: 2));
                            switchLamp(
                                ip: widget.ip,
                                key: widget.keys,
                                code: e,
                                id_order: "0",
                                status: false);
                            await Future.delayed(const Duration(seconds: 1));
                            popScreen(context);
                          });
                        } else {
                          switchLamp(
                              ip: widget.ip,
                              key: widget.keys,
                              code: widget.code,
                              id_order: "0",
                              status: true);
                          await Future.delayed(const Duration(seconds: 2));
                          switchLamp(
                              ip: widget.ip,
                              key: widget.keys,
                              code: widget.code,
                              id_order: "0",
                              status: false);
                          await Future.delayed(const Duration(seconds: 1));
                          popScreen(context);
                        }
                      },
                      child: Container(
                        width: 55.w,
                        decoration: const BoxDecoration(
                            color: ColorConstant.primary,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        height: 30.w,
                        child: Center(
                          child: Text(
                            "RESET",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp, color: Colors.white),
                          ),
                        ),
                      )),
                ],
              )
            ],
          ),
        ));
  }
}
