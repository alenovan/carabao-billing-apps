import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constant/url_constant.dart';
import '../../helper/global_helper.dart';
import '../models/auth/RequestLoginModels.dart';
import '../models/auth/ResponseLoginModels.dart';

abstract class LoginRepo {
  Future<ResponseLoginModels> actLogin(RequestLoginModels payload);
}

class LoginRepoRepositoryImpl implements LoginRepo {
  @override
  Future<ResponseLoginModels> actLogin(RequestLoginModels payload) async {
    // TODO: implement actLogin
    var body = jsonEncode(payload);
    var response = await http.post(Uri.parse(UrlConstant.login),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseLoginModels responses =
          responseLoginModelsFromJson(response.body);
      return responses;
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }
}
