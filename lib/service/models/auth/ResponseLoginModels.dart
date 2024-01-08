// To parse this JSON data, do
//
//     final responseLoginModels = responseLoginModelsFromJson(jsonString);

import 'dart:convert';

ResponseLoginModels responseLoginModelsFromJson(String str) => ResponseLoginModels.fromJson(json.decode(str));

String responseLoginModelsToJson(ResponseLoginModels data) => json.encode(data.toJson());

class ResponseLoginModels {
  bool? success;
  String? message;
  String? token;

  ResponseLoginModels({
    this.success,
    this.message,
    this.token,
  });

  factory ResponseLoginModels.fromJson(Map<String, dynamic> json) => ResponseLoginModels(
    success: json["success"],
    message: json["message"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "token": token,
  };
}
