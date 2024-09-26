import 'dart:async';

import 'package:carabaobillingapps/constant/color_constant.dart';
import 'package:carabaobillingapps/screen/room/RoomScreen.dart';
import 'package:carabaobillingapps/service/models/order/RequestStopOrdersModels.dart';
import 'package:carabaobillingapps/service/repository/OrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart'; // Import for playing sound
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/data_constant.dart';
import '../constant/image_constant.dart';
import '../helper/BottomSheetFeedback.dart';
import '../helper/global_helper.dart';
import '../helper/shared_preference.dart';
import '../service/bloc/order/order_bloc.dart';

class MenuListCard extends StatefulWidget {
  final bool status;
  final String name;
  final String idMeja;
  final String? idOrder;
  final String code;
  final String end;
  final String start;
  final String type;
  final String ip;
  final String keys;
  final Function() onUpdate;

  MenuListCard({
    super.key,
    required this.status,
    required this.name,
    required this.end,
    required this.code,
    required this.idMeja,
    required this.type,
    required this.start,
    this.idOrder,
    required this.ip,
    required this.keys,
    required this.onUpdate,
  });

  @override
  State<MenuListCard> createState() => _MenuListCardState();
}

class _MenuListCardState extends State<MenuListCard> {
  Duration _remainingTime = Duration.zero;
  DateTime? _startTime;
  Timer? _timer;
  OrderBloc? _orderBloc;
  late bool statusLocal;
  bool isOrange = true;
  Color _currentBackgroundColor = ColorConstant.white;

  Future<bool> getAutoCutSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_cut') ?? false;
  }

  Future<bool> getSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound') ?? true;
  }

  @override
  void initState() {
    super.initState();
    _orderBloc = OrderBloc(repository: OrderRepoRepositoryImpl(context));
    statusLocal = widget.status;

    if (widget.type == "OPEN-BILLING" &&
        widget.end != "No orders" &&
        widget.status) {
      _startOpenBillingTimer();
    } else if (widget.type == "OPEN-TABLE" && widget.status) {
      _startOpenTableTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _orderBloc?.close();
    super.dispose();
  }

  Widget _consumerApi() {
    return Column(
      children: [
        BlocConsumer<OrderBloc, OrderState>(
          listener: (c, s) {
            if (s is OrdersStopOpenBillingLoadedState) {
              // Reset to default color and status
              setState(() {
                _currentBackgroundColor =
                    ColorConstant.white; // Reset background color
                statusLocal = false; // Update status to ready
              });
              switchLamp(
                  ip: s.result.data!.panel!.ip!,
                  key: s.result.data!.panel!.secret!,
                  code: s.result.data!.code!,
                  status: false);
              FlutterRingtonePlayer().stop();
            }
            // Handle other states as necessary
          },
          builder: (c, s) {
            return Container();
          },
        ),
      ],
    );
  }

  void _startOpenBillingTimer() async {
    DateTime endTime = DateTime.parse(widget.end);
    _remainingTime = endTime.difference(DateTime.now());
    bool autoCut = await getAutoCutSetting();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - Duration(seconds: 1);
        });
      } else {
        widget.onUpdate();
        timer.cancel();

        if (autoCut) {
          _orderBloc?.add(ActStopOrderOpenAutoBilling(
            payload:
                RequestStopOrdersModels(orderId: int.parse(widget.idOrder!)),
          ));
        }
      }

      if (_remainingTime.inMinutes <= 1) {
        _toggleBlinkingEffect();
      }

      if (_remainingTime.inSeconds <= 0) {
        _handleEndOfBilling();
      }
    });
  }

  void _startOpenTableTimer() {
    _startTime = DateTime.parse(widget.start);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = DateTime.now().difference(_startTime!);
      });
    });
  }

  void _toggleBlinkingEffect() {
    setState(() {
      isOrange = !isOrange;
      _currentBackgroundColor = isOrange ? Colors.orange : Colors.white;
    });
  }

  void _handleEndOfBilling() async {
    bool soundEnabled = await getSoundSetting();
    setState(() {
      _currentBackgroundColor = Colors.red;
    });
    if (soundEnabled) {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
        looping: true,
        volume: 1.0,
        asAlarm: true,
      );
    }
  }

  Widget _buildStatusText() {
    if (widget.type == "OPEN-BILLING") {
      if (!widget.status) {
        if (widget.start != "No orders" && widget.end != "No orders") {
          // Calculate time difference
          DateTime startTime = DateTime.parse(widget.start);
          DateTime endTime = DateTime.parse(widget.end);
          Duration difference = endTime.difference(startTime);

          return Text(
            "OPEN-BILLING - ${_formatDuration(difference)}",
            style: _subTextStyle(),
          );
        } else {
          return Text("OPEN-BILLING", style: _subTextStyle());
        }
      }
      if (_remainingTime.inSeconds <= 0) {
        return Text(
          "Habis Matikan Lampu",
          style: _subTextStyle().copyWith(color: Colors.white),
        );
      }
      if (_remainingTime != Duration.zero) {
        return Text(
          "${_formatDuration(_remainingTime)} Lagi Habis",
          style: _subTextStyle(),
        );
      }
    } else if (widget.type == "OPEN-TABLE") {
      // Check if both start and end are not "No orders"
      if (widget.start != "No orders" && widget.end != "No orders") {
        // Calculate time difference
        DateTime startTime = DateTime.parse(widget.start);
        DateTime endTime = DateTime.parse(widget.end);
        Duration difference = endTime.difference(startTime);

        return Text(
          "Open Table - ${_formatDuration(difference)}",
          style: _subTextStyle(),
        );
      } else {
        // If either start or end is "No orders"
        return Text(
          "Open Table - ${_formatDuration(_remainingTime)}",
          style: _subTextStyle(),
        );
      }
    }
    return SizedBox();
  }

  TextStyle _subTextStyle() {
    return GoogleFonts.plusJakartaSans(
        fontSize: 10.sp, color: ColorConstant.subtext);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(create: (_) => _orderBloc!),
      ],
      child: InkWell(
        onTap: () async {
          var timerSetting = await getStringValuesSF(ConstantData.is_timer);
          if (timerSetting == "1") {
            FlutterRingtonePlayer().stop();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => RoomScreen(meja_id: widget.idMeja)));
          } else {
            BottomSheetFeedback.showError(context, "Mohon Maaf",
                "Akun anda tidak di izinkan untuk menjalankan billing");
          }
        },
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _currentBackgroundColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 2)),
            ],
          ),
          padding: EdgeInsets.all(15.w),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetails(),
                  _buildStatusBadge(),
                ],
              ),
              _consumerApi()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Row(
      children: [
        Image.asset(ImageConstant.xinjue, width: 50.w),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            _buildStatusText(),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      width: statusLocal ? 75.w : 55.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: statusLocal ? ColorConstant.error : ColorConstant.success,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          statusLocal ? "In Use" : "Ready",
          style:
              GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: Colors.white),
        ),
      ),
    );
  }
}
