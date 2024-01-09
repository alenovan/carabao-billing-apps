import 'dart:convert';

import 'package:carabaobillingapps/service/models/order/RequestOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/RequestStopOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseStopOrdersModels.dart';
import 'package:http/http.dart' as http;

import '../../constant/url_constant.dart';
import '../../helper/global_helper.dart';

abstract class OrderRepo {
  Future<ResponseListOrdersModels> getOrder();

  Future<ResponseOrdersModels> order(RequestOrdersModels payload);

  Future<ResponseStopOrdersModels> stop_order(RequestStopOrdersModels payload);
}

class OrderRepoRepositoryImpl implements OrderRepo {
  @override
  Future<ResponseListOrdersModels> getOrder() async {
    // TODO: implement getOrder
    var response = await http.get(Uri.parse(UrlConstant.newest_orders),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseListOrdersModels responses =
          responseListOrdersModelsFromJson(response.body);
      return responses;
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future<ResponseOrdersModels> order(RequestOrdersModels payload) async {
    // TODO: implement updateOrder
    var body = jsonEncode(payload);
    var response = await http.post(Uri.parse(UrlConstant.order),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseOrdersModels responses =
          responseOrdersModelsFromJson(response.body);
      return responses;
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future<ResponseStopOrdersModels> stop_order(
      RequestStopOrdersModels payload) async {
    // TODO: implement stop_order
    var body = jsonEncode(payload);
    var response = await http.post(Uri.parse(UrlConstant.stoporder),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseStopOrdersModels responses =
          responseStopOrdersModelsFromJson(response.body);
      return responses;
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }
}
