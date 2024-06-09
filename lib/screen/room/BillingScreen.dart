import 'package:boxicons/boxicons.dart';
import 'package:carabaobillingapps/service/bloc/order/order_bloc.dart';
import 'package:carabaobillingapps/service/models/order/RequestOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/RequestStopOrdersModels.dart';
import 'package:carabaobillingapps/service/repository/OrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../component/loading_dialog.dart';
import '../../constant/color_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../helper/global_helper.dart';
import '../../helper/navigation_utils.dart';
import '../../main.dart';
import '../BottomNavigationScreen.dart';

class BillingScreen extends StatefulWidget {
  final String id_meja;
  final String code;
  final bool status;
  final String? id_order;
  final String ip;
  final String keys;

  const BillingScreen(
      {super.key,
      required this.id_meja,
      required this.code,
      required this.status,
      this.id_order,
      required this.ip,
      required this.keys});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late String selected_time = "Choose Hours";
  late int selected_time_nunber;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _OrderBloc = OrderBloc(repository: OrderRepoRepositoryImpl());

  SharedPreferences? _prefs;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
  }

  void showNameInputDialog(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Masukkan Detail Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Nama Pemesan'),
              ),
              SizedBox(height: 8.0), // Add some space between the text fields
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(hintText: 'Nomor Whatsapp'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Batalkan'),
            ),
            ElevatedButton(
              onPressed: () {
                String enteredName = _nameController.text;
                String enteredPhone = _phoneController.text;
                _OrderBloc.add(ActOrderOpenBilling(
                    payload: RequestOrdersModels(
                        idRooms: widget.id_meja,
                        name: enteredName,
                        phone: enteredPhone,
                        duration: selected_time_nunber.toString())));
              },
              child: Text('Simpan'),
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
              switchLamp(
                  ip: widget.ip,
                  key: widget.keys,
                  code: widget.code,
                  status: true);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BottomNavigationScreen()));
            } else if (s is OrdersStopLoadedState) {
              popScreen(context);
              BottomSheetFeedback.showSuccess(
                  context, "Selamat", s.result.message!);
              switchLamp(
                  ip: widget.ip,
                  key: widget.keys,
                  code: widget.code,
                  status: false);
              NavigationUtils.navigateTo(
                  context, const BottomNavigationScreen(), true);
            } else if (s is OrdersErrorState) {
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
          onTap: () {
            showNameInputDialog(context);
          },
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
    );
  }

  Widget orderFound() {
    return GestureDetector(
      onTap: () {
        removeNotification(widget.id_order!);
        removeOrderFromPrefs(widget.id_order!);
        removeAllNotifications();
        initPrefs();
        stopCountdown(widget.id_order!);
        _OrderBloc.add(ActStopOrderOpenBilling(
            payload: RequestStopOrdersModels(
                orderId: int.parse(widget.id_order.toString()))));
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
            "OFF BILLING",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
                color: ColorConstant.white),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
          providers: [
            BlocProvider<OrderBloc>(
              create: (BuildContext context) => _OrderBloc,
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
