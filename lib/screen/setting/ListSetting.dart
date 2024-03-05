import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../component/menu_list_control.dart';
import '../../constant/color_constant.dart';
import '../../helper/BottomSheetFeedback.dart';
import '../../helper/global_helper.dart';
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
  late dynamic meja = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _MejaBloc.add(GetMeja());
  }

  Widget _consumerApi() {
    return Column(
      children: [
        BlocConsumer<MejaBloc, MejaState>(
          listener: (c, s) {
            if (s is MejaLoadingState) {
            } else if (s is MejaLoadedState) {
              setState(() {
                meja = s.result.rooms!;
              });
            } else if (s is MejaErrorState) {
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
        title: Text('List Table'),
      ),
      body: MultiBlocProvider(
          providers: [
            BlocProvider<MejaBloc>(
              create: (BuildContext context) => _MejaBloc,
            ),
          ],
          child: Container(
            child: Stack(
              children: [
                _consumerApi(),
                ListView.builder(
                  itemCount: meja?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    var data = meja[i] as Room;
                    return MenuListControl(
                      name: data.name!,
                      code: data.code!,
                      ip: data.ip!,
                      keys: data.secret!,
                    );
                  },
                )
              ],
            ),
          )),
    );
  }
}
