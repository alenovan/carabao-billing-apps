import 'dart:convert';
import 'dart:developer';

import 'package:carabaobillingapps/service/models/configs/RequestConfigsModels.dart';
import 'package:carabaobillingapps/service/models/configs/ResponseConfigsModels.dart';
import 'package:carabaobillingapps/service/models/configs/ResponseListConfigModels.dart';
import 'package:http/http.dart' as http;

import '../../constant/url_constant.dart';
import '../../helper/global_helper.dart';

abstract class ConfigRepo {
  Future<ResponseListConfigModels> getConfig();

  Future<ResponseConfigsModels> updateConfig(RequestConfigsModels payload);

  Future<dynamic> logout();
}

class ConfigRepoRepositoryImpl implements ConfigRepo {
  @override
  Future<ResponseListConfigModels> getConfig() async {
    // TODO: implement getConfig
    var response = await http.get(Uri.parse(UrlConstant.config),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseListConfigModels responses =
          responseListConfigModelsFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future<ResponseConfigsModels> updateConfig(
      RequestConfigsModels payload) async {
    // TODO: implement updateConfig
    var body = jsonEncode(payload);
    var response = await http.post(Uri.parse(UrlConstant.config),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseConfigsModels responses =
          responseConfigsModelsFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future logout() async {
    var body = jsonEncode({});
    var response = await http.post(Uri.parse(UrlConstant.logout),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      log(response.body);
      return true;
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }
}
