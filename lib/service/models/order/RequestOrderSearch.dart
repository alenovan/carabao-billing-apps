// To parse this JSON data, do
//
//     final requestOrderSearch = requestOrderSearchFromJson(jsonString);

import 'dart:convert';

RequestOrderSearch requestOrderSearchFromJson(String str) => RequestOrderSearch.fromJson(json.decode(str));

String requestOrderSearchToJson(RequestOrderSearch data) => json.encode(data.toJson());

class RequestOrderSearch {
  String? search;

  RequestOrderSearch({
    this.search,
  });

  factory RequestOrderSearch.fromJson(Map<String, dynamic> json) => RequestOrderSearch(
    search: json["search"],
  );

  Map<String, dynamic> toJson() => {
    "search": search,
  };
}
