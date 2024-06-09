import 'dart:convert';

import 'package:carabaobillingapps/constant/data_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../component/menu_list_control.dart';
import '../../constant/color_constant.dart';
import '../../service/bloc/meja/meja_bloc.dart';
import '../../service/repository/RoomsRepository.dart';

class ListSetting extends StatefulWidget {
  const ListSetting({super.key});

  @override
  State<ListSetting> createState() => _ListSettingState();
}

class _ListSettingState extends State<ListSetting> {
  final _MejaBloc = MejaBloc(repository: RoomsRepoRepositoryImpl());
  late TextEditingController searchController = TextEditingController();
  List<dynamic> data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    searchController.text = ConstantData.ip_default;
  }

  fetchData() async {
    String jsonString = '''
      {
        "status": true,
        "message": "Data Berhasil di ambil",
        "data": [
          {
            "id": 1,
            "name": "Meja 1",
            "code": "mj_1_"
          },
          {
            "id": 2,
            "name": "Meja 2",
            "code": "mj_2_"
          },
          {
            "id": 3,
            "name": "Meja 3",
            "code": "mj_3_"
          },
          {
            "id": 4,
            "name": "Meja 4",
            "code": "mj_4_"
          },
          {
            "id": 5,
            "name": "Meja 5",
            "code": "mj_5_"
          },
          {
            "id": 6,
            "name": "Meja 6",
            "code": "mj_6_"
          },
          {
            "id": 7,
            "name": "Meja 7",
            "code": "mj_7_"
          },
          {
            "id": 8,
            "name": "Meja 8",
            "code": "mj_8_"
          },
          {
            "id": 9,
            "name": "Meja 9",
            "code": "mj_9_"
          },
          {
            "id": 10,
            "name": "Meja 10",
            "code": "mj_10_"
          },
          {
            "id": 11,
            "name": "Meja 11",
            "code": "mj_11_"
          },
          {
            "id": 12,
            "name": "Meja 12",
            "code": "mj_12_"
          },
          {
            "id": 13,
            "name": "Meja 13",
            "code": "mj_13_"
          },
          {
            "id": 14,
            "name": "Meja 14",
            "code": "mj_17_"
          },
          {
            "id": 15,
            "name": "Meja 15",
            "code": "mj_18_"
          },
          {
            "id": 16,
            "name": "Meja 16",
            "code": "mj_19_"
          },
          {
            "id": 17,
            "name": "Meja 17",
            "code": "mj_20_"
          },
          {
            "id": 18,
            "name": "Meja 18",
            "code": "mj_21_"
          },
          {
            "id": 19,
            "name": "Meja 19",
            "code": "mj_22_"
          },
          {
            "id": 20,
            "name": "Meja 20",
            "code": "mj_23_"
          },
          {
            "id": 21,
            "name": "Meja 21",
            "code": "mj_24_"
          }
        ]
      }
    ''';

    setState(() {
      data = json.decode(jsonString)['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bg,
      appBar: AppBar(
        title: Text('List Table'),
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
                Container(
                  margin: EdgeInsets.all(20.w),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Ip',
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
                    onChanged: (e) {
                      setState(() {
                        ConstantData.ip_default = e;
                        searchController.text = e;
                      });
                    },
                    // Add controller and other TextFormField properties as needed
                  ),
                ),
                ListView.builder(
                  itemCount: data.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return MenuListControl(
                      name: data[index]['name'],
                      code: data[index]['code'],
                      ip: searchController.text,
                      keys: ConstantData.key_config,
                    );
                  },
                )
              ],
            ),
          )),
    );
  }
}
