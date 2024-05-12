// To parse this JSON data, do
//
//     final responseOrdersOpenBillingModels = responseOrdersOpenBillingModelsFromJson(jsonString);

import 'dart:convert';

ResponseOrdersOpenBillingModels responseOrdersOpenBillingModelsFromJson(String str) => ResponseOrdersOpenBillingModels.fromJson(json.decode(str));

String responseOrdersOpenBillingModelsToJson(ResponseOrdersOpenBillingModels data) => json.encode(data.toJson());

class ResponseOrdersOpenBillingModels {
  bool? success;
  String? message;
  Order? order;

  ResponseOrdersOpenBillingModels({
    this.success,
    this.message,
    this.order,
  });

  factory ResponseOrdersOpenBillingModels.fromJson(Map<String, dynamic> json) => ResponseOrdersOpenBillingModels(
    success: json["success"],
    message: json["message"],
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "order": order?.toJson(),
  };
}

class Order {
  int? id;
  String? idRooms;
  int? idUsers;
  String? startTime;
  String? endTime;
  String? status;
  String? type;
  String? name;

  Order({
    this.id,
    this.idRooms,
    this.idUsers,
    this.startTime,
    this.endTime,
    this.status,
    this.type,
    this.name,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    idRooms: json["id_rooms"],
    idUsers: json["id_users"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    status: json["status"],
    type: json["type"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_rooms": idRooms,
    "id_users": idUsers,
    "start_time": startTime,
    "end_time": endTime,
    "status": status,
    "type": type,
    "name": name,
  };
}
