// To parse this JSON data, do
//
//     final responseRoomsModels = responseRoomsModelsFromJson(jsonString);

import 'dart:convert';

ResponseRoomsModels responseRoomsModelsFromJson(String str) => ResponseRoomsModels.fromJson(json.decode(str));

String responseRoomsModelsToJson(ResponseRoomsModels data) => json.encode(data.toJson());

class ResponseRoomsModels {
  bool? success;
  List<Room>? rooms;

  ResponseRoomsModels({
    this.success,
    this.rooms,
  });

  factory ResponseRoomsModels.fromJson(Map<String, dynamic> json) => ResponseRoomsModels(
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
  String? name;
  String? code;
  dynamic createdAt;
  dynamic updateAt;
  int? status;
  int? idPanels;
  int? roomsAvailable;
  String? position;
  String? ip;
  int? isActive;
  String? secret;

  Room({
    this.id,
    this.name,
    this.code,
    this.createdAt,
    this.updateAt,
    this.status,
    this.idPanels,
    this.roomsAvailable,
    this.position,
    this.ip,
    this.isActive,
    this.secret,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    createdAt: json["created_at"],
    updateAt: json["update_at"],
    status: json["status"],
    idPanels: json["id_panels"],
    roomsAvailable: json["rooms_available"],
    position: json["position"],
    ip: json["ip"],
    isActive: json["is_active"],
    secret: json["secret"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "created_at": createdAt,
    "update_at": updateAt,
    "status": status,
    "id_panels": idPanels,
    "rooms_available": roomsAvailable,
    "position": position,
    "ip": ip,
    "is_active": isActive,
    "secret": secret,
  };
}
