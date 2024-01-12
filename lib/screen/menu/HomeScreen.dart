import 'package:carabaobillingapps/constant/data_constant.dart';
import 'package:carabaobillingapps/service/bloc/order/order_bloc.dart';
import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:carabaobillingapps/service/repository/OrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/menu_list_card.dart';
import '../../constant/image_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../helper/shared_preference.dart';
import '../../service/bloc/configs/configs_bloc.dart';
import '../../service/repository/ConfigRepository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _OrderBloc = OrderBloc(repository: OrderRepoRepositoryImpl());
  final _ConfigsBloc = ConfigsBloc(repository: ConfigRepoRepositoryImpl());
  late List<NewestOrder>? NewestOrders = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _OrderBloc.add(GetOrder());
    _ConfigsBloc.add(GetConfig());
  }

  Widget _consumerApi() {
    return Column(
      children: [
        BlocConsumer<OrderBloc, OrderState>(
          listener: (c, s) {
            if (s is OrdersLoadingState) {
            } else if (s is OrdersListLoadedState) {
              setState(() {
                NewestOrders = s.result.newestOrders;
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
              await addStringSf(ConstantData.ip, s.result.rooms![0].ip!);
              await addStringSf(ConstantData.key, s.result.rooms![0].secret!);
            } else if (s is ConfigsErrorState) {}
          },
          builder: (c, s) {
            return Container();
          },
        ),
      ],
    );
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
                  );
                },
              )
            ],
          )),
    );
  }
}
