import 'package:boxicons/boxicons.dart';
import 'package:carabaobillingapps/screen/LoginScreen.dart';
import 'package:carabaobillingapps/service/bloc/configs/configs_bloc.dart';
import 'package:carabaobillingapps/service/repository/ConfigRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/loading_dialog.dart';
import '../../constant/color_constant.dart';
import '../../constant/image_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../helper/global_helper.dart';
import '../setting/ListSetting.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _ConfigsBloc = ConfigsBloc(repository: ConfigRepoRepositoryImpl());
  late TextEditingController ipdController = TextEditingController();

  Widget _consumerApi() {
    return Column(
      children: [
        BlocConsumer<ConfigsBloc, ConfigsState>(
          listener: (c, s) {
            if (s is ConfigsLoadingState) {
              LoadingDialog.show(c, "Mohon tunggu");
            } else if (s is ConfigsLoadedState) {
              popScreen(context);
              BottomSheetFeedback.showSuccess(
                  context, "Selamat", s.result.message.toString());
            } else if (s is ConfigsListLoadedState) {
              setState(() {
                ipdController.text = s.result.rooms![0].ip.toString() ?? "";
              });
            } else if (s is ConfigsErrorState) {
              popScreen(c);
              BottomSheetFeedback.showError(context, "Mohon Maaf", s.message);
            }
          },
          builder: (c, s) {
            return Container();
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ConfigsBloc.add(GetConfig());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MultiBlocProvider(
            providers: [
              BlocProvider<ConfigsBloc>(
                create: (BuildContext context) => _ConfigsBloc,
              ),
            ],
            child:ListView(
      children: [
        _consumerApi(),
        Container(
          child: Column(
            children: [
              Image.asset(
                ImageConstant.logo,
                width: 150.w,
              ),
              Text(
                "Billiards Lamp Controls",
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.plusJakartaSans(fontSize: 15.sp, color: Colors.black),
              ),
            ],
          ),
        ),
        // Container(
        //   margin: EdgeInsets.all(20.w),
        //   decoration: BoxDecoration(
        //     color: ColorConstant.white,
        //     borderRadius: BorderRadius.all(Radius.circular(15)),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.1),
        //         blurRadius: 2.0,
        //         spreadRadius: 1.0,
        //         offset: Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   padding: EdgeInsets.all(15.w),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       TextFormField(
        //         decoration: InputDecoration(
        //           labelText: 'Enter IP Address',
        //           labelStyle: GoogleFonts.plusJakartaSans(
        //             fontSize: 12.sp,
        //             color: Colors.grey,
        //           ),
        //           border: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(10.0),
        //             borderSide: BorderSide(
        //               color: ColorConstant.borderinput,
        //             ),
        //           ),
        //           contentPadding:
        //               EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.w),
        //         ),
        //         controller: ipdController,
        //         // Add controller and other TextFormField properties as needed
        //       ),
        //     ],
        //   ),
        // ),
        // GestureDetector(
        //   onTap: () {
        //     _ConfigsBloc.add(ActConfig(payload: RequestConfigsModels(
        //       ip: ipdController.text.toString()
        //     )));
        //   },
        //   child: Container(
        //     decoration: BoxDecoration(
        //         border: Border.all(
        //           color: ColorConstant.primary,
        //         ),
        //         color: ColorConstant.primary,
        //         borderRadius: BorderRadius.all(Radius.circular(50))),
        //     height: 50.w,
        //     margin: EdgeInsets.all(20.w),
        //     padding: EdgeInsets.only(left: 20.w, right: 20.w),
        //     child: Center(
        //       child: Text(
        //         "Simpan",
        //         textAlign: TextAlign.center,
        //         style: GoogleFonts.plusJakartaSans(
        //             fontSize: 11.sp, color: ColorConstant.white),
        //       ),
        //     ),
        //   ),
        // ),
        InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListSetting()),
              );
            },
            child: Container(
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
                        "Table List Control",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                            color: ColorConstant.titletext),
                      ),
                      Icon(
                        Boxicons.bx_chevron_right,
                        color: ColorConstant.subtext,
                      )
                    ],
                  ),
                ))),
        InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Container(
                margin: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: ColorConstant.off,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Logout",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                            color: ColorConstant.white),
                      ),
                    ],
                  ),
                ))),
      ],
    )));
  }
}
