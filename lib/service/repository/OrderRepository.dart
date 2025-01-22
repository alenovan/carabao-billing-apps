import 'dart:convert';

import 'package:carabaobillingapps/service/models/order/RequestChangeTable.dart';
import 'package:carabaobillingapps/service/models/order/RequestOrderSearch.dart';
import 'package:carabaobillingapps/service/models/order/RequestOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/RequestStopOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/RequestVoidOrder.dart';
import 'package:carabaobillingapps/service/models/order/ResponseChangeTable.dart';
import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseOrderHistoryModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseStopOrdersModels.dart';
import 'package:carabaobillingapps/service/models/order/ResponseVoidOrder.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../../constant/url_constant.dart';
import '../../helper/api_helper.dart';
import '../../helper/global_helper.dart';
import '../models/order/ResponseDetailHistory.dart';
import '../models/order/ResponseOrdersBgModels.dart';
import '../models/order/ResponseOrdersOpenBillingModels.dart';

final Map<String, Future<ResponseStopOrdersModels>> _ongoingRequests = {};
final Map<String, DateTime> _lastRequestTime = {};

abstract class OrderRepo {
  Future<ResponseListOrdersModels> getOrder();

  Future<ResponseOrdersBgModels> getOrderBg();

  Future<ResponseOrdersOpenBillingModels> order_open_billing(
      RequestOrdersModels payload);

  Future<ResponseStopOrdersModels> stop_order_open_billing(
      RequestStopOrdersModels payload);

  Future<ResponseOrdersModels> order_open_table(RequestOrdersModels payload);

  Future<ResponseStopOrdersModels> stop_order_open_table(
      RequestStopOrdersModels payload);

  Future<ResponseOrderHistoryModels> OrderHistory(RequestOrderSearch payload);

  Future<ResponseChangeTable> changeTable(RequestChangeTable payload);

  Future<ResponseVoidOrder> voidTable(RequestVoidOrder payload);

  Future<ResponseDetailHistory> historyDetail(String id);

  Future<ResponseListOrdersModels> getOrdersDetail(String id);
}

class OrderRepoRepositoryImpl implements OrderRepo {
  final Client _client;

  OrderRepoRepositoryImpl() : _client = ApiHelper.build();

  @override
  Future<ResponseListOrdersModels> getOrder() async {
    // TODO: implement getOrder
    var response = await _client.get(Uri.parse(UrlConstant.newest_orders),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseListOrdersModels responses =
          responseListOrdersModelsFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 400 ||
        response.statusCode == 504 ||
        response.statusCode == 500) {
      throw ("Silahkan Ulangi Kembali");
    } else if (response.statusCode == 401) {
      throw ("Silahkan Login Kembali ya");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future<ResponseOrdersBgModels> getOrderBg() async {
    // TODO: implement getOrder
    var response = await _client.get(Uri.parse(UrlConstant.newest_orders_bg),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseOrdersBgModels responses =
          responseOrdersBgModelsFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 400 ||
        response.statusCode == 504 ||
        response.statusCode == 500) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future<ResponseOrdersOpenBillingModels> order_open_billing(
      RequestOrdersModels payload) async {
    // TODO: implement updateOrder
    var body = jsonEncode(payload);
    var response = await _client.post(Uri.parse(UrlConstant.order_open_billing),
        body: body, headers: await tokenHeader(true));

    if (response.statusCode == 200) {
      ResponseOrdersOpenBillingModels responses =
          responseOrdersOpenBillingModelsFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 400 ||
        response.statusCode == 504 ||
        response.statusCode == 500) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future<ResponseStopOrdersModels> stop_order_open_billing(
      RequestStopOrdersModels payload) async {
    final url = UrlConstant.order_stop_billing;
    final body = jsonEncode(payload);

    // Use orderId as the unique key for the request
    final requestKey = payload.orderId.toString();

    // Check if there is an ongoing request with the same orderId
    if (_ongoingRequests.containsKey(requestKey)) {
      return _ongoingRequests[requestKey]!;
    }

    // Check if the last request for this orderId was made less than 2 minutes ago
    final now = DateTime.now();
    if (_lastRequestTime.containsKey(requestKey) &&
        now.difference(_lastRequestTime[requestKey]!).inMinutes < 2) {
      throw ("Request for this order ID was made less than 2 minutes ago.");
    }

    try {
      // Create a new request and store it in the ongoing requests map
      final request = _client
          .post(Uri.parse(url), body: body, headers: await tokenHeader(true))
          .then((response) {
        if (response.statusCode == 200) {
          return ResponseStopOrdersModels.fromJson(jsonDecode(response.body));
        } else if ([522, 502, 400, 504, 500].contains(response.statusCode)) {
          throw ("Silahkan Ulangi Kembali");
        } else {
          final responses = jsonDecode(response.body);
          throw ("${responses["message"]}");
        }
      });

      _ongoingRequests[requestKey] = request; // Save the Future in the map

      // Await the result, update the last request time, and remove the entry after completion
      final result = await request;
      _lastRequestTime[requestKey] = now; // Update the last request time
      _ongoingRequests.remove(requestKey);
      return result;
    } catch (e) {
      // Ensure cleanup in case of an error
      _ongoingRequests.remove(requestKey);
      rethrow;
    }
  }

  @override
  Future<ResponseOrdersModels> order_open_table(
      RequestOrdersModels payload) async {
    // TODO: implement updateOrder
    var body = jsonEncode(payload);
    var response = await _client.post(Uri.parse(UrlConstant.order_open_table),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseOrdersModels responses =
          responseOrdersModelsFromJson(response.body);
      return responses;
    } else if (response.statusCode == 400) {
      throw ("Room sudah di book");
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 504 ||
        response.statusCode == 500) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future<ResponseStopOrdersModels> stop_order_open_table(
      RequestStopOrdersModels payload) async {
    // TODO: implement stop_order
    var body = jsonEncode(payload);
    var response = await _client.post(Uri.parse(UrlConstant.order_stop_table),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseStopOrdersModels responses =
          responseStopOrdersModelsFromJson(response.body);
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
  Future<ResponseOrderHistoryModels> OrderHistory(
      RequestOrderSearch payload) async {
    // TODO: implement OrderHistory
    var body = jsonEncode(payload);
    var response = await _client.post(Uri.parse(UrlConstant.history_orders),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseOrderHistoryModels responses =
          responseOrderHistoryModelsFromJson(response.body);
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
  Future<ResponseChangeTable> changeTable(RequestChangeTable payload) async {
    // TODO: implement changeTable
    var body = jsonEncode(payload);
    var response = await _client.post(Uri.parse(UrlConstant.change_table),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseChangeTable responses =
          responseChangeTableFromJson(response.body);
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
  Future<ResponseVoidOrder> voidTable(RequestVoidOrder payload) async {
    // TODO: implement voidTable
    var body = jsonEncode(payload);
    var response = await _client.post(Uri.parse(UrlConstant.void_table),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseVoidOrder responses = responseVoidOrderFromJson(response.body);
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
  Future<ResponseDetailHistory> historyDetail(String id) async {
    // TODO: implement historyDetail
    var response = await _client.get(Uri.parse(UrlConstant.detail_history + id),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseDetailHistory responses =
          responseDetailHistoryFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 504 ||
        response.statusCode == 500) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }

  @override
  Future<ResponseListOrdersModels> getOrdersDetail(String id) async {
    // TODO: implement getOrdersDetail
    var response = await _client.get(
        Uri.parse("${UrlConstant.newest_orders}/$id"),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseListOrdersModels responses =
          responseListOrdersModelsFromJson(response.body);
      return responses;
    } else if (response.statusCode == 522 ||
        response.statusCode == 502 ||
        response.statusCode == 504 ||
        response.statusCode == 500) {
      throw ("Silahkan Ulangi Kembali");
    } else {
      var responses = jsonDecode(response.body);
      throw ("${responses["message"]}");
    }
  }
}
