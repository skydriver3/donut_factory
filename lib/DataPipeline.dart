import 'dart:convert' as convert;

import 'package:donut_factory/HomePage.dart';
import 'package:http/http.dart' as http;

class OrderForm {
  String pickup;
  String donuts;
  String done;
  String date;
  String runner;

  OrderForm(this.pickup, this.donuts, this.done, this.date, this.runner);

  factory OrderForm.fromJson(dynamic json) {
    return OrderForm("${json["pickup"]}", "${json["qty"]}", "${json["done"]}",
        "${json["date"]}", "${json["runner"]}");
  }

  Map<String, String> toJson() => {
        "pickup": pickup,
        "qty": donuts,
        "done": done,
        "date": date,
        "runner": runner
      };
}

class DataPipeline {
  static const String URL =
      "https://script.google.com/macros/s/AKfycbzvD7JFs9QjK3F6vYGEoEp-Xhy7SlVj2odFMRdnZ6n10or9PIU5iCRb7UupSmy294EDiA/exec";
  static const STATUS_SUCCESS = "SUCCESS";

  void submitForm(OrderForm form, void Function(String) callback) async {
    try {
      var json = form.toJson();
      await http.post(URL, body: json).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(url).then((response2) {
            callback(convert.jsonDecode(response2.body)["status"]);
          });
        } else {
          callback(convert.jsonDecode(response.body)["status"]);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
