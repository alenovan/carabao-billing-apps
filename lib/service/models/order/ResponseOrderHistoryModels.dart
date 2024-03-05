// To parse this JSON data, do
//
//     final responseOrderHistoryModels = responseOrderHistoryModelsFromJson(jsonString);

import 'dart:convert';

ResponseOrderHistoryModels responseOrderHistoryModelsFromJson(String str) => ResponseOrderHistoryModels.fromJson(json.decode(str));

String responseOrderHistoryModelsToJson(ResponseOrderHistoryModels data) => json.encode(data.toJson());

class ResponseOrderHistoryModels {
  bool? success;
  List<MatchedOrder>? matchedOrders;

  ResponseOrderHistoryModels({
    this.success,
    this.matchedOrders,
  });

  factory ResponseOrderHistoryModels.fromJson(Map<String, dynamic> json) => ResponseOrderHistoryModels(
    success: json["success"],
    matchedOrders: json["matchedOrders"] == null ? [] : List<MatchedOrder>.from(json["matchedOrders"]!.map((x) => MatchedOrder.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "matchedOrders": matchedOrders == null ? [] : List<dynamic>.from(matchedOrders!.map((x) => x.toJson())),
  };
}

class MatchedOrder {
  int? roomId;
  String? code;
  String? name;
  int? statusRooms;
  String? statusOrder;
  String? type;
  String? ordersName;
  int? id;
  DateTime? startTime;
  DateTime? endTime;

  MatchedOrder({
    this.roomId,
    this.code,
    this.name,
    this.statusRooms,
    this.statusOrder,
    this.type,
    this.ordersName,
    this.id,
    this.startTime,
    this.endTime,
  });

  factory MatchedOrder.fromJson(Map<String, dynamic> json) => MatchedOrder(
    roomId: json["room_id"],
    code: json["code"],
    name: json["name"],
    statusRooms: json["status_rooms"],
    statusOrder: json["status_order"],
    type: json["type"],
    ordersName: json["orders_name"],
    id: json["id"],
    startTime: json["start_time"] == null ? null : DateTime.parse(json["start_time"]),
    endTime: json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
  );

  Map<String, dynamic> toJson() => {
    "room_id": roomId,
    "code": code,
    "name": name,
    "status_rooms": statusRooms,
    "status_order": statusOrder,
    "type": type,
    "orders_name": ordersName,
    "id": id,
    "start_time": startTime?.toIso8601String(),
    "end_time": endTime?.toIso8601String(),
  };
}
