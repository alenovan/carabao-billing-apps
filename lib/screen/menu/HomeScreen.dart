import 'dart:convert';

import 'package:carabaobillingapps/constant/data_constant.dart';
import 'package:carabaobillingapps/main.dart';
import 'package:carabaobillingapps/service/bloc/order/order_bloc.dart';
import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:carabaobillingapps/service/repository/OrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../component/menu_list_card.dart';
import '../../component/shimmerx.dart';
import '../../constant/image_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../helper/shared_preference.dart';
import '../../service/bloc/configs/configs_bloc.dart';
import '../../service/repository/ConfigRepository.dart';
import '../BottomNavigationScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _OrderBloc = OrderBloc(repository: OrderRepoRepositoryImpl());
  final _ConfigsBloc = ConfigsBloc(repository: ConfigRepoRepositoryImpl());
  late List<NewestOrder>? NewestOrders = [];
  late bool loading = true;

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  List<Map<String, dynamic>> _orders = [];
  late CountdownTimer _countdownTimer;
  final int _updateIntervalSeconds = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _OrderBloc.add(GetOrder());
    // _OrderBloc.add(GetOrderBg());
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // _countdownTimer.cancel();
    _OrderBloc.close();
    super.dispose();
  }

  Future<void> saveData(List<NewestOrder> orders) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    // Reset the existing data to null
    await _prefs.remove('orders');

    // Convert the input orders to a list of JSON objects
    List<Map<String, dynamic>> _newOrders = orders.map((order) => order.toJson()).toList();

    // Encode the list of new orders and save to SharedPreferences
    final String newOrdersJson = json.encode(_newOrders);
    await _prefs.setString('orders', newOrdersJson);
    initPrefs();
  }

  Widget _consumerApi() {
    return Column(
      children: [
        BlocConsumer<OrderBloc, OrderState>(
          listener: (c, s) {
            // if (s is OrdersListBgLoadedState) {
            //   setState(() {
            //     saveData(s.result!.data!);
            //   });
            //
            // }
            if (s is OrdersLoadingState) {
            } else if (s is OrdersListLoadedState) {
              List<NewestOrder> filteredOrders = s.result.data!.where((order) {
                return order.type == 'OPEN-BILLING' && order.statusOrder == 'START';
              }).toList();
              setState(() {
                saveData(filteredOrders);
                NewestOrders = s.result.data;
                loading = false;
              });
            } else if (s is OrdersErrorState) {
              BottomSheetFeedback.showError(context, "Mohon Maaf", s.message);
            }
          },
          builder: (c, s) {
            return Container();
          },
        ),
        BlocConsumer<ConfigsBloc, ConfigsState>(
          listener: (c, s) async {
            if (s is ConfigsLoadingState) {
            } else if (s is ConfigsLoadedState) {
            } else if (s is ConfigsListLoadedState) {
              try {
                await addStringSf(ConstantData.ip, s.result.rooms![0].ip!);
                await addStringSf(ConstantData.key, s.result.rooms![0].secret!);
              } catch (e) {}
            } else if (s is ConfigsErrorState) {}
          },
          builder: (c, s) {
            return Container();
          },
        ),
      ],
    );
  }

  Future<void> _refreshList() async {
    _OrderBloc.add(GetOrder());
    _OrderBloc.add(GetOrderBg());
    setState(() {
      loading = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: MultiBlocProvider(
          providers: [
            BlocProvider<OrderBloc>(
              create: (BuildContext context) => _OrderBloc,
            ),
            BlocProvider<ConfigsBloc>(
              create: (BuildContext context) => _ConfigsBloc,
            ),
          ],
          child: RefreshIndicator(
          onRefresh: _refreshList,
          child: ListView(
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
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.w,
              ),
              if (loading)
                ListView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return Container(
                      margin: EdgeInsets.all(8.w),
                      height: 80.w,
                      child: Shimmerx(),
                    );
                  },
                ),
              if (!loading)
                ListView.builder(
                  itemCount: NewestOrders?.length ?? 0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    var data = NewestOrders![i];
                    return MenuListCard(
                      status: data.statusRooms == 0 ? false : true,
                      name: data.name!,
                      id_order: data.id.toString(),
                      code: data.code!,
                      start: data.newestOrderStartTime!,
                      end: data.newestOrderEndTime!,
                      id_meja: data.roomId.toString(),
                      type: data.type.toString(),
                      ip: data.ip!,
                      keys: data.secret!,
                      onUpdate: () {
                        _OrderBloc.add(GetOrder());
                      },
                    );
                  },
                )
            ],
          ))),
    );
  }
}
