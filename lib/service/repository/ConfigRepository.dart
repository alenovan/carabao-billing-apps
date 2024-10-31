import 'dart:convert';
import 'dart:developer';

import 'package:carabaobillingapps/service/models/configs/RequestConfigsModels.dart';
import 'package:carabaobillingapps/service/models/configs/ResponseConfigsModels.dart';

import '../../constant/url_constant.dart';
import '../../helper/global_helper.dart';
import '../models/configs/ResponseClientInformation.dart';
import 'package:http/http.dart';
import '../../helper/api_helper.dart';

abstract class ConfigRepo {
  Future<ResponseClientInformation> getConfig();

  Future<ResponseConfigsModels> updateConfig(RequestConfigsModels payload);

  Future<dynamic> logout();
}

class ConfigRepoRepositoryImpl implements ConfigRepo {
  final Client _client;

  ConfigRepoRepositoryImpl() : _client = ApiHelper.build();

  @override
  Future<ResponseClientInformation> getConfig() async {
    // TODO: implement getConfig
    var response = await _client.get(Uri.parse(UrlConstant.config),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseClientInformation responses =
          responseClientInformationFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 504 ||
        response.statusCode == 400 ||
        response.statusCode == 500) {
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
    var response = await _client.post(Uri.parse(UrlConstant.config),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseConfigsModels responses =
          responseConfigsModelsFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 504 ||
        response.statusCode == 400 ||
        response.statusCode == 500) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future logout() async {
    var body = jsonEncode({});
    var response = await _client.post(Uri.parse(UrlConstant.logout),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      log(response.body);
      return true;
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 504 ||
        response.statusCode == 400 ||
        response.statusCode == 500) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }
}
