// To parse this JSON data, do
//
//     final responsePanelModels = responsePanelModelsFromJson(jsonString);

import 'dart:convert';

ResponsePanelModels responsePanelModelsFromJson(String str) => ResponsePanelModels.fromJson(json.decode(str));

String responsePanelModelsToJson(ResponsePanelModels data) => json.encode(data.toJson());

class ResponsePanelModels {
  bool? success;
  List<Room>? rooms;

  ResponsePanelModels({
    this.success,
    this.rooms,
  });

  factory ResponsePanelModels.fromJson(Map<String, dynamic> json) => ResponsePanelModels(
    success: json["success"],
    rooms: json["rooms"] == null ? [] : List<Room>.from(json["rooms"]!.map((x) => Room.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "rooms": rooms == null ? [] : List<dynamic>.from(rooms!.map((x) => x.toJson())),
  };
}

class Room {
  int? id;
  String? position;
  String? ip;
  int? isActive;
  String? secret;

  Room({
    this.id,
    this.position,
    this.ip,
    this.isActive,
    this.secret,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json["id"],
    position: json["position"],
    ip: json["ip"],
    isActive: json["is_active"],
    secret: json["secret"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "position": position,
    "ip": ip,
    "is_active": isActive,
    "secret": secret,
  };
}
