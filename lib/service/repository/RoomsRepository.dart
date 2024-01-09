import 'dart:convert';

import 'package:carabaobillingapps/service/models/rooms/ResponseRoomsModels.dart';
import 'package:http/http.dart' as http;

import '../../constant/url_constant.dart';
import '../../helper/global_helper.dart';

abstract class RoomsRepo {
  Future<ResponseRoomsModels> getRooms();

  Future<dynamic> openRooms(String link);
}

class RoomsRepoRepositoryImpl implements RoomsRepo {
  @override
  Future<ResponseRoomsModels> getRooms() async {
    // TODO: implement getRooms
    var response = await http.get(Uri.parse(UrlConstant.rooms),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseRoomsModels responses =
          responseRoomsModelsFromJson(response.body);
      return responses;
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future openRooms(String link) async {
    // TODO: implement openRooms
    var response =
        await http.post(Uri.parse(link), headers: await tokenHeader(true));
    throw ("Oke");
  }
}
