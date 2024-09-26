import 'dart:convert';

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
import '../../constant/color_constant.dart';
import '../../constant/image_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../service/bloc/configs/configs_bloc.dart';
import '../../service/bloc/meja/meja_bloc.dart';
import '../../service/repository/ConfigRepository.dart';
import '../../service/repository/RoomsRepository.dart';
import '../BottomNavigationScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  OrderBloc? _OrderBloc;
  final _ConfigsBloc = ConfigsBloc(repository: ConfigRepoRepositoryImpl());
  late List<NewestOrder>? NewestOrders = [];
  late bool loading = true;
  final _MejaBloc = MejaBloc(repository: RoomsRepoRepositoryImpl());
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  List<Map<String, dynamic>> _orders = [];
  late CountdownTimer _countdownTimer;
  final int _updateIntervalSeconds = 1;
  var firstOpen = true;

  @override
  void initState() {
    // TODO: implement initState
    _OrderBloc = OrderBloc(repository: OrderRepoRepositoryImpl(context));
    _MejaBloc?.add(GetMeja());
    super.initState();
    _OrderBloc?.add(GetOrder());
    // _OrderBloc.add(GetOrderBg());
    WidgetsBinding.instance?.addObserver(this);
    Registerbackgroun(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // _countdownTimer.cancel();
    _OrderBloc?.close();
    super.dispose();
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
                return order.type == 'OPEN-BILLING' &&
                    order.statusOrder == 'START';
              }).toList();
              setState(() {
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
        BlocConsumer<MejaBloc, MejaState>(
          listener: (c, s) async {
            if (s is MejaLoadedState) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('result_meja', jsonEncode(s.result.toJson()));
            }
          },
          builder: (c, s) {
            return Container();
          },
        ),
      ],
    );
  }

  Future<void> _refreshList() async {
    _OrderBloc?.add(GetOrder());
    _OrderBloc?.add(GetOrderBg());
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
              create: (BuildContext context) => _OrderBloc!,
            ),
            BlocProvider<ConfigsBloc>(
              create: (BuildContext context) => _ConfigsBloc,
            ),
            BlocProvider<MejaBloc>(
              create: (BuildContext context) => _MejaBloc,
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
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(""),
                        GestureDetector(
                          onTap: () {
                            _refreshList();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: ColorConstant.primary,
                                ),
                                color: ColorConstant.primary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: 30.w,
                            margin: EdgeInsets.only(right: 10.w),
                            padding: EdgeInsets.only(left: 20.w, right: 20.w),
                            child: Center(
                              child: Text(
                                "Refresh",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    color: ColorConstant.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.w,
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
                  if (!loading && NewestOrders != null)
                    Builder(
                      builder: (context) {
                        List<NewestOrder> reorderedOrders = [...NewestOrders!];

                        // reorderedOrders.sort((a, b) {
                        //   // Priority 1: Orders with statusRooms == 1 and type == "OPEN-BILLING"
                        //   if (a.statusRooms == 1 &&
                        //       a.type == "OPEN-BILLING" &&
                        //       (b.statusRooms != 1 ||
                        //           b.type != "OPEN-BILLING")) {
                        //     return -1; // Move 'statusRooms == 1' and 'OPEN-BILLING' to the top
                        //   } else if (b.statusRooms == 1 &&
                        //       b.type == "OPEN-BILLING" &&
                        //       (a.statusRooms != 1 ||
                        //           a.type != "OPEN-BILLING")) {
                        //     return 1; // Keep other orders below
                        //   }
                        //
                        //   // Priority 2: Orders with type == "OPEN-BILLING"
                        //   if (a.type == "OPEN-BILLING" &&
                        //       b.type != "OPEN-BILLING") {
                        //     return -1; // Move 'OPEN-BILLING' to the top
                        //   } else if (b.type == "OPEN-BILLING" &&
                        //       a.type != "OPEN-BILLING") {
                        //     return 1; // Keep other orders below
                        //   }
                        //
                        //   // Otherwise, keep the same order
                        //   return 0;
                        // });

                        return ListView.builder(
                          itemCount: reorderedOrders.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            var data = reorderedOrders[i];
                            return MenuListCard(
                              status: data.statusRooms == 0 ? false : true,
                              name: data.name!,
                              idOrder: data.id.toString(),
                              code: data.code!,
                              start: data.newestOrderStartTime!,
                              end: data.newestOrderEndTime!,
                              idMeja: data.roomId.toString(),
                              type: data.type.toString(),
                              ip: data.ip!,
                              keys: data.secret!,
                              onUpdate: () {
                                _OrderBloc?.add(GetOrder());
                              },
                            );
                          },
                        );
                      },
                    ),
                ],
              ))),
    );
  }
}
