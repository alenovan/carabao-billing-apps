// To parse this JSON data, do
//
//     final responseOrdersModels = responseOrdersModelsFromJson(jsonString);

import 'dart:convert';

ResponseOrdersModels responseOrdersModelsFromJson(String str) => ResponseOrdersModels.fromJson(json.decode(str));

String responseOrdersModelsToJson(ResponseOrdersModels data) => json.encode(data.toJson());

class ResponseOrdersModels {
  bool? success;
  String? message;

  ResponseOrdersModels({
    this.success,
    this.message,
  });

  factory ResponseOrdersModels.fromJson(Map<String, dynamic> json) => ResponseOrdersModels(
    success: json["success"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };
}
