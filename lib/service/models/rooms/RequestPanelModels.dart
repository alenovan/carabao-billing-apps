// To parse this JSON data, do
//
//     final requestPanelModels = requestPanelModelsFromJson(jsonString);

import 'dart:convert';

RequestPanelModels requestPanelModelsFromJson(String str) => RequestPanelModels.fromJson(json.decode(str));

String requestPanelModelsToJson(RequestPanelModels data) => json.encode(data.toJson());

class RequestPanelModels {
  String? ip;

  RequestPanelModels({
    this.ip,
  });

  factory RequestPanelModels.fromJson(Map<String, dynamic> json) => RequestPanelModels(
    ip: json["ip"],
  );

  Map<String, dynamic> toJson() => {
    "ip": ip,
  };
}
