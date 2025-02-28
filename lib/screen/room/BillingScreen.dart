import 'dart:convert';
import 'dart:io';

import 'package:boxicons/boxicons.dart';
import 'package:carabaobillingapps/constant/data_constant.dart';
import 'package:carabaobillingapps/service/bloc/order/order_bloc.dart';
import 'package:carabaobillingapps/service/models/order/RequestChangeTable.dart';
import 'package:carabaobillingapps/service/models/order/RequestOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/RequestStopOrdersModels.dart';
import 'package:carabaobillingapps/service/repository/OrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../component/loading_dialog.dart';
import '../../constant/color_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../helper/global_helper.dart';
import '../../helper/navigation_utils.dart';
import '../../service/bloc/meja/meja_bloc.dart';
import '../../service/models/rooms/ResponseRoomsModels.dart';
import '../../service/repository/RoomsRepository.dart';
import '../BottomNavigationScreen.dart';

class BillingScreen extends StatefulWidget {
  final String id_meja;
  final String code;
  final bool status;
  final String? id_order;
  final String ip;
  final String keys;
  final int isMuiltiple;
  final String multipleChannel;

  const BillingScreen(
      {super.key,
      required this.id_meja,
      required this.code,
      required this.status,
      this.id_order,
      required this.ip,
      required this.keys,
      required this.isMuiltiple,
      required this.multipleChannel});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late String selected_time = "Choose Hours";
  late int selected_time_nunber;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  OrderBloc? _OrderBloc;
  final _MejaBloc = MejaBloc(repository: RoomsRepoRepositoryImpl());
  late List<Room>? data_meja = [];
  SharedPreferences? _prefs;
  final List<Map<String, dynamic>> _orders = [];
  bool loadingMeja = true;

  void _startBackgroundTimer(String endTime, String orderId) {
    final service = FlutterBackgroundService();
    service.startService();
    service
        .invoke('startBillingTimer', {"endTime": endTime, "orderId": orderId});
  }

  @override
  void initState() {
    _OrderBloc = OrderBloc(repository: OrderRepoRepositoryImpl());
    _MejaBloc.add(GetMeja());
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _OrderBloc?.close();
    _MejaBloc.close();
    super.dispose();
  }

  void showNameInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Masukkan Detail Pelanggan (Open Billing)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Nama Pemesan'),
              ),
              const SizedBox(
                  height: 8.0), // Add some space between the text fields
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(hintText: 'Nomor Whatsapp'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Batalkan'),
            ),
            ElevatedButton(
              onPressed: () {
                String enteredName = _nameController.text;
                String enteredPhone = _phoneController.text;
                _OrderBloc?.add(ActOrderOpenBilling(
                    payload: RequestOrdersModels(
                        idRooms: widget.id_meja,
                        name: enteredName,
                        phone: enteredPhone,
                        version: ConstantData.version_apps,
                        duration: selected_time_nunber.toString())));
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _consumerApi() {
    return Column(
      children: [
        BlocConsumer<OrderBloc, OrderState>(
          listener: (c, s) async {
            if (s is OrdersLoadingState) {
              LoadingDialog.show(c, "Mohon tunggu");
            } else if (s is OrdersLoadedOpenBillingState) {
              popScreen(context);
              BottomSheetFeedback.showSuccess(
                  context, "Selamat", s.result.message!);
              String endTime = s.result.data?.endTime?.toIso8601String() ?? "";
              // Retrieve endTime and orderId from the state
              String orderId = s.result.data?.id?.toString() ??
                  ""; // Assuming `id` is available in data

              if (endTime.isNotEmpty && orderId.isNotEmpty) {
                if (Platform.isAndroid) {
                  _startBackgroundTimer(endTime,
                      orderId); // Start the background service with timer
                }
              }
              if (widget.isMuiltiple == 1) {
                List<dynamic> multipleChannelList =
                    jsonDecode(widget.multipleChannel);
                for (var e in multipleChannelList) {
                  switchLamp(
                    ip: widget.ip,
                    key: widget.keys,
                    id_order: widget.id_order ?? "-1",
                    code: e,
                    status: true,
                  );
                }
              } else {
                switchLamp(
                    ip: widget.ip,
                    key: widget.keys,
                    code: widget.code,
                    id_order: widget.id_order ?? "-1",
                    status: true);
              }
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BottomNavigationScreen()));
            } else if (s is OrdersStopLoadedState) {
              popScreen(context);
              BottomSheetFeedback.showSuccess(
                  context, "Selamat", s.result.message!);
              if (widget.isMuiltiple == 1) {
                List<dynamic> multipleChannelList =
                    jsonDecode(widget.multipleChannel);
                for (var e in multipleChannelList) {
                  switchLamp(
                    ip: widget.ip,
                    key: widget.keys,
                    id_order: widget.id_order ?? "-1",
                    code: e,
                    status: false,
                  );
                }
              } else {
                switchLamp(
                    ip: widget.ip,
                    key: widget.keys,
                    code: widget.code,
                    id_order: widget.id_order ?? "-1",
                    status: false);
              }
              NavigationUtils.navigateTo(
                  context, const BottomNavigationScreen(), true);
            } else if (s is OrdersErrorState) {
              popScreen(c);
              BottomSheetFeedback.showError(context, "Mohon Maaf", s.message);
            }

            if (s is OrdersChangeTableLoadingState) {
              LoadingDialog.show(c, "Mohon tunggu");
            } else if (s is OrdersChangeTableLoadedState) {
              popScreen(context);
              BottomSheetFeedback.showSuccess(
                  context, "Selamat", s.result.message!);
              if (ConstantData.lamp_connection) {
                RoomsRepoRepositoryImpl().openRooms(s.result.data!.oldRooms!);
                await Future.delayed(const Duration(seconds: 2));
                RoomsRepoRepositoryImpl().openRooms(s.result.data!.newRooms!);
              }

              NavigationUtils.navigateTo(
                  context, const BottomNavigationScreen(), false);
            } else if (s is OrdersChangetableErrorState) {
              popScreen(c);
              BottomSheetFeedback.showError(context, "Mohon Maaf", s.message);
            }
          },
          builder: (c, s) {
            return Container();
          },
        ),
        BlocConsumer<MejaBloc, MejaState>(
          listener: (c, s) {
            if (s is MejaLoadedState) {
              setState(() {
                loadingMeja = false;
                data_meja = s.result.data!
                    .where((room) =>
                        (room.status == 0 && room.isMultipleChannel == 0))
                    .toList();
              });
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
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
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

  void _showBottomSheetChangeMeja(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 800.h, // Use height unit for responsive height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: data_meja?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    Room detailMeja = data_meja![index];
                    return ListTile(
                      title: Text(detailMeja.name ?? ""),
                      onTap: () {
                        _OrderBloc?.add(ActChangetableTable(
                            payload: RequestChangeTable(
                                idOrder: int.parse(widget.id_order!),
                                idRooms: detailMeja.id)));
                        // Handle item tap
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget orderNotFound() {
    return Column(
      children: [
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Boxicons.bx_alarm,
                          color: ColorConstant.alarm,
                        ),
                        const SizedBox(
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
                              selected_time,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15.sp,
                                  color: ColorConstant.titletext),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Icon(
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
          onTap: () {
            showNameInputDialog(context);
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: ColorConstant.primary,
                ),
                color: ColorConstant.primary,
                borderRadius: const BorderRadius.all(Radius.circular(50))),
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
    );
  }

  Widget orderFound() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _OrderBloc?.add(ActStopOrderOpenBilling(
                payload: RequestStopOrdersModels(
                    orderId: int.parse(widget.id_order.toString()))));
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: ColorConstant.off,
                ),
                color: ColorConstant.off,
                borderRadius: const BorderRadius.all(Radius.circular(50))),
            height: 50.w,
            margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.w),
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Center(
              child: Text(
                "Off Billing",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                    color: ColorConstant.white),
              ),
            ),
          ),
        ),
        loadingMeja
            ? Container(
                margin: EdgeInsets.only(top: 10.w),
                child: const CircularProgressIndicator(),
              )
            : widget.isMuiltiple == 1
                ? Container()
                : GestureDetector(
                    onTap: () {
                      _showBottomSheetChangeMeja(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorConstant.primary,
                          ),
                          color: ColorConstant.primary,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50))),
                      height: 50.w,
                      margin:
                          EdgeInsets.only(left: 20.w, right: 20.w, top: 10.w),
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: Center(
                        child: Text(
                          "Change Table",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                              color: ColorConstant.white),
                        ),
                      ),
                    ),
                  ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
          providers: [
            BlocProvider<OrderBloc>(
              create: (BuildContext context) => _OrderBloc!,
            ),
            BlocProvider<MejaBloc>(
              create: (BuildContext context) => _MejaBloc,
            ),
          ],
          child: Column(
            children: [
              _consumerApi(),
              SizedBox(
                height: 50.w,
              ),
              if (widget.status) orderFound(),
              if (!widget.status) orderNotFound()
            ],
          )),
    );
  }
}
