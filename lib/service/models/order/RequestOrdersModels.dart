// To parse this JSON data, do
//
//     final requestOrdersModels = requestOrdersModelsFromJson(jsonString);

import 'dart:convert';

RequestOrdersModels requestOrdersModelsFromJson(String str) => RequestOrdersModels.fromJson(json.decode(str));

String requestOrdersModelsToJson(RequestOrdersModels data) => json.encode(data.toJson());

class RequestOrdersModels {
  String? idRooms;
  String? duration;
  String name;

  RequestOrdersModels({
    this.idRooms,
    this.duration,
    required this.name,
  });

  factory RequestOrdersModels.fromJson(Map<String, dynamic> json) => RequestOrdersModels(
    idRooms: json["id_rooms"],
    duration: json["duration"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id_rooms": idRooms,
    "duration": duration,
    "name": name,
  };
}
