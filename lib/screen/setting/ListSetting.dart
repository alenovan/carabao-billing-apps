import 'dart:convert';

import 'package:carabaobillingapps/constant/data_constant.dart';
import 'package:carabaobillingapps/screen/BottomNavigationScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../component/menu_list_control.dart';
import '../../constant/color_constant.dart';
import '../../service/bloc/meja/meja_bloc.dart';
import '../../service/models/rooms/ResponseRoomsModels.dart';
import '../../service/repository/RoomsRepository.dart';

class ListSetting extends StatefulWidget {
  const ListSetting({super.key});

  @override
  State<ListSetting> createState() => _ListSettingState();
}

class _ListSettingState extends State<ListSetting> {
  final _MejaBloc = MejaBloc(repository: RoomsRepoRepositoryImpl());
  late TextEditingController searchController = TextEditingController();
  ResponseRoomsModels? data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    searchController.text = ConstantData.ip_default;
  }

  fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('result_meja');
    if (jsonString != null) {
      setState(() {
        data = ResponseRoomsModels.fromJson(json.decode(jsonString));
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: ColorConstant.bg,
          appBar: AppBar(
            title: const Text('List Table'),
          ),
          body: MultiBlocProvider(
              providers: [
                BlocProvider<MejaBloc>(
                  create: (BuildContext context) => _MejaBloc,
                ),
              ],
              child: Container(
                child: ListView(
                  children: [
                    ListView.builder(
                      itemCount: data?.data?.length ?? 0,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return MenuListControl(
                          name: data!.data![index].name!,
                          code: data!.data![index].code!,
                          ip: data!.data![index].ip ?? "",
                          position: data!.data![index].position,
                          keys: data!.data![index].secret ?? "",
                          isMuiltiple: data!.data![index].isMultipleChannel,
                          multipleChannel:
                              data!.data![index].multipleChannel ?? "",
                        );
                      },
                    )
                  ],
                ),
              )),
        ),
        onWillPop: () async {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationScreen(
                        defaultMenuIndex: 2,
                      )));
          return false;
        });
  }
}
