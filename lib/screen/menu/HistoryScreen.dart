import 'package:carabaobillingapps/service/bloc/order/order_bloc.dart';
import 'package:carabaobillingapps/service/models/order/RequestOrderSearch.dart';
import 'package:carabaobillingapps/service/repository/OrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/color_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../helper/global_helper.dart';
import '../../service/models/order/ResponseOrderHistoryModels.dart';
import '../component/ItemListHistory.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _OrderBloc = OrderBloc(repository: OrderRepoRepositoryImpl());
  late dynamic order = [];
  late TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _OrderBloc.add(ActOrderHistory(payload: RequestOrderSearch(search: "")));
  }

  Widget _consumerApi() {
    return Column(
      children: [
        BlocConsumer<OrderBloc, OrderState>(
          listener: (c, s) {
            if (s is OrdersLoadingState) {
            } else if (s is OrdersHistoryLoadedState) {
              setState(() {
                order = s.result.matchedOrders;
              });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bg,
      appBar: AppBar(
        title: Text('History Order'),
      ),
      body: MultiBlocProvider(
          providers: [
            BlocProvider<OrderBloc>(
              create: (BuildContext context) => _OrderBloc,
            ),
          ],
          child: Container(
            child: Column(
              children: [
                _consumerApi(),
                Container(
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
                  padding: EdgeInsets.all(5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Cari Nama',
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: ColorConstant.borderinput,
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 2.w, horizontal: 16.w),
                        ),
                        controller: searchController,
                        onChanged: (e){
                          _OrderBloc.add(ActOrderHistory(payload: RequestOrderSearch(search: e)));
                        },
                        // Add controller and other TextFormField properties as needed
                      ),
                    ],
                  ),
                ),



                ListView.builder(
                  itemCount: order?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    var data = order[i] as MatchedOrder;
                    DateTime endTime = DateTime.parse(data.endTime.toString());
                    Duration difference = endTime.difference(DateTime.parse(data.startTime.toString()));
                    var _remainingTime = Duration(seconds: difference.inSeconds);
                    return Container(
                      margin: EdgeInsets.only(
                          left: 20.w, right: 20.w, bottom: 10.w),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ItemListHistory(title: "Nama",value: data.ordersName.toString(),),
                          ItemListHistory(title: "Meja",value: data.name.toString(),),
                          ItemListHistory(title: "Waktu Mulai",value: data.startTime.toString(),),
                          ItemListHistory(title: "Waktu Selesai",value: data.endTime.toString(),),
                          ItemListHistory(title: "Total Selesai",value: formatDuration(_remainingTime!),)
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          )),
    );
  }
}
