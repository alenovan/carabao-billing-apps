// To parse this JSON data, do
//
//     final responseStopOrdersModels = responseStopOrdersModelsFromJson(jsonString);

import 'dart:convert';

ResponseStopOrdersModels responseStopOrdersModelsFromJson(String str) => ResponseStopOrdersModels.fromJson(json.decode(str));

String responseStopOrdersModelsToJson(ResponseStopOrdersModels data) => json.encode(data.toJson());

class ResponseStopOrdersModels {
  bool? status;
  String? message;
  String? data;

  ResponseStopOrdersModels({
    this.status,
    this.message,
    this.data,
  });

  factory ResponseStopOrdersModels.fromJson(Map<String, dynamic> json) => ResponseStopOrdersModels(
    status: json["status"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };
}
