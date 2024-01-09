import 'package:carabaobillingapps/service/models/order/RequestStopOrdersModels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/loading_dialog.dart';
import '../../constant/color_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../helper/global_helper.dart';
import '../../helper/navigation_utils.dart';
import '../../service/bloc/order/order_bloc.dart';
import '../../service/models/order/RequestOrdersModels.dart';
import '../../service/repository/OrderRepository.dart';
import '../BottomNavigationScreen.dart';

class OpenTableScreen extends StatefulWidget {
  final String code;
  final String id_meja;
  final bool status;
  final String? id_order;

  const OpenTableScreen(
      {super.key,
      required this.code,
      required this.id_meja,
      required this.status,
      this.id_order});

  @override
  State<OpenTableScreen> createState() => _OpenTableScreenState();
}

class _OpenTableScreenState extends State<OpenTableScreen> {
  final _OrderBloc = OrderBloc(repository: OrderRepoRepositoryImpl());

  Widget _consumerApi() {
    return Column(
      children: [
        BlocConsumer<OrderBloc, OrderState>(
          listener: (c, s) async {
            if (s is OrdersLoadingState) {
              LoadingDialog.show(c, "Mohon tunggu");
            } else if (s is OrdersLoadedState || s is OrdersStopLoadedState) {
              popScreen(context);
              BottomSheetFeedback.showSuccess(
                  context, "Selamat", "Selamat Berhasil");
              switchLamp(widget.code, true);
              NavigationUtils.navigateTo(
                  context, const BottomNavigationScreen(), false);
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
              if (!widget.status)
                GestureDetector(
                  onTap: () async {
                    _OrderBloc.add(ActOrderOpenTable(
                        payload: RequestOrdersModels(idRooms: widget.id_meja)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorConstant.on,
                        ),
                        color: ColorConstant.on,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    height: 50.w,
                    margin: EdgeInsets.only(left: 20.w, right: 20.w),
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: Center(
                      child: Text(
                        "ON",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                            color: ColorConstant.white),
                      ),
                    ),
                  ),
                ),
              if (widget.status)
                GestureDetector(
                  onTap: () {
                    _OrderBloc.add(ActStopOrderOpenTable(
                        payload:
                            RequestStopOrdersModels(orderId: int.parse(
                                widget.id_order.toString()))));
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
                        "OFF",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                            color: ColorConstant.white),
                      ),
                    ),
                  ),
                )
            ],
          )),
    );
  }
}
