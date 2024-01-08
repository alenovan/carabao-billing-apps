// To parse this JSON data, do
//
//     final responseStopOrdersModels = responseStopOrdersModelsFromJson(jsonString);

import 'dart:convert';

ResponseStopOrdersModels responseStopOrdersModelsFromJson(String str) => ResponseStopOrdersModels.fromJson(json.decode(str));

String responseStopOrdersModelsToJson(ResponseStopOrdersModels data) => json.encode(data.toJson());

class ResponseStopOrdersModels {
  bool? success;
  String? message;

  ResponseStopOrdersModels({
    this.success,
    this.message,
  });

  factory ResponseStopOrdersModels.fromJson(Map<String, dynamic> json) => ResponseStopOrdersModels(
    success: json["success"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };
}
