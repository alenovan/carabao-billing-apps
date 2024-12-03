import 'dart:async';
import 'dart:convert';

import 'package:carabaobillingapps/constant/data_constant.dart';
import 'package:carabaobillingapps/service/models/rooms/RequestPanelModels.dart';
import 'package:carabaobillingapps/service/models/rooms/ResponseRoomsModels.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../constant/url_constant.dart';
import '../../helper/api_helper.dart';
import '../../helper/global_helper.dart';
import '../models/rooms/ResponsePanelModels.dart';
import '../models/rooms/ResponseUpdatePanelModels.dart';

abstract class RoomsRepo {
  Future<ResponseRoomsModels> getRooms();

  Future<dynamic> openRooms(String link);

  Future<ResponsePanelModels> getPanel();

  Future<ResponseUpdatePanelModels> updatePanel(
      RequestPanelModels payload, String id);
}

class RoomsRepoRepositoryImpl implements RoomsRepo {
  final Client _client;
  RoomsRepoRepositoryImpl() : _client = ApiHelper.build();

  @override
  Future<ResponseRoomsModels> getRooms() async {
    // TODO: implement getRooms
    var response = await _client.get(Uri.parse(UrlConstant.rooms),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      print(222);
      ResponseRoomsModels responses =
          responseRoomsModelsFromJson(response.body);
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
  Future<http.Response?> openRooms(String link) async {
    // Check if lamp connection is active
    if (ConstantData.lamp_connection) {
      print(link);
      try {
        var response = await http
            .post(
              Uri.parse(link),
              headers: await tokenHeader(
                  true), // Assuming tokenHeader is defined elsewhere
            )
            .timeout(const Duration(seconds: 5)); // Set the timeout duration

        if (response.statusCode == 200) {
          print("Rooms opened successfully");
        } else {
          print("Failed to open rooms. Status code: ${response.statusCode}");
        }

        return response; // Return the HTTP response
      } on TimeoutException catch (e) {
        print('The request to open rooms timed out: $e');
        // Handle timeout logic here (e.g., notify user, retry)
        return null;
      } catch (error) {
        print('Error during openRooms request: $error');
        // Handle other errors (network, server, etc.)
        return null;
      }
    }

    return null;
  }

  @override
  Future<ResponsePanelModels> getPanel() async {
    // TODO: implement getPanel
    var response = await _client.get(Uri.parse(UrlConstant.panels),
        headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponsePanelModels responses =
          responsePanelModelsFromJson(response.body);
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
  Future<ResponseUpdatePanelModels> updatePanel(
      RequestPanelModels payload, String id) async {
    // TODO: implement updatePanel
    var body = jsonEncode(payload);
    var response = await _client.post(Uri.parse(UrlConstant.panelsupdate),
        body: body, headers: await tokenHeader(true));
    if (response.statusCode == 200) {
      ResponseUpdatePanelModels responses =
          responseUpdatePanelModelsFromJson(response.body);
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
