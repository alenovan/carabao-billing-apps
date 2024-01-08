// To parse this JSON data, do
//
//     final requestOrdersModels = requestOrdersModelsFromJson(jsonString);

import 'dart:convert';

RequestOrdersModels requestOrdersModelsFromJson(String str) => RequestOrdersModels.fromJson(json.decode(str));

String requestOrdersModelsToJson(RequestOrdersModels data) => json.encode(data.toJson());

class RequestOrdersModels {
  String? idRooms;
  String? idUsers;
  DateTime? startTime;
  DateTime? endTime;
  String? status;

  RequestOrdersModels({
    this.idRooms,
    this.idUsers,
    this.startTime,
    this.endTime,
    this.status,
  });

  factory RequestOrdersModels.fromJson(Map<String, dynamic> json) => RequestOrdersModels(
    idRooms: json["id_rooms"],
    idUsers: json["id_users"],
    startTime: json["start_time"] == null ? null : DateTime.parse(json["start_time"]),
    endTime: json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id_rooms": idRooms,
    "id_users": idUsers,
    "start_time": startTime?.toIso8601String(),
    "end_time": endTime?.toIso8601String(),
    "status": status,
  };
}
