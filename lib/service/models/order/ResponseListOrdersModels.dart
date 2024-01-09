// To parse this JSON data, do
//
//     final responseListOrdersModels = responseListOrdersModelsFromJson(jsonString);

import 'dart:convert';

ResponseListOrdersModels responseListOrdersModelsFromJson(String str) => ResponseListOrdersModels.fromJson(json.decode(str));

String responseListOrdersModelsToJson(ResponseListOrdersModels data) => json.encode(data.toJson());

class ResponseListOrdersModels {
  bool? success;
  List<NewestOrder>? newestOrders;

  ResponseListOrdersModels({
    this.success,
    this.newestOrders,
  });

  factory ResponseListOrdersModels.fromJson(Map<String, dynamic> json) => ResponseListOrdersModels(
    success: json["success"],
    newestOrders: json["newestOrders"] == null ? [] : List<NewestOrder>.from(json["newestOrders"]!.map((x) => NewestOrder.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "newestOrders": newestOrders == null ? [] : List<dynamic>.from(newestOrders!.map((x) => x.toJson())),
  };
}

class NewestOrder {
  int? roomId;
  String? code;
  String? name;
  int? statusRooms;
  String? statusOrder;
  DateTime? newestOrderEndTime;

  NewestOrder({
    this.roomId,
    this.code,
    this.name,
    this.statusRooms,
    this.statusOrder,
    this.newestOrderEndTime,
  });

  factory NewestOrder.fromJson(Map<String, dynamic> json) => NewestOrder(
    roomId: json["room_id"],
    code: json["code"],
    name: json["name"],
    statusRooms: json["status_rooms"],
    statusOrder: json["status_order"],
    newestOrderEndTime: json["newest_order_end_time"] == null ? null : DateTime.parse(json["newest_order_end_time"]),
  );

  Map<String, dynamic> toJson() => {
    "room_id": roomId,
    "code": code,
    "name": name,
    "status_rooms": statusRooms,
    "status_order": statusOrder,
    "newest_order_end_time": newestOrderEndTime?.toIso8601String(),
  };
}
