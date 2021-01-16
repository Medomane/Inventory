
import 'package:flutter/widgets.dart';

import 'User.dart';
import '../Helpers/sqlite.dart';

class Item{
  int id;
  String reference;
  String designation;
  String code;
  String family;
  String num;
  double sellingPrice;
  double buyingPrice;
  double inStock;
  String extension;
  dynamic image;
  String uniqueId;

  static Future<Item> get(int id) async {
    var data = await SqLite.select("SELECT * FROM item WHERE id = $id");
    if(data.length <= 0) return null;
    var res = data[0];
    var item = new Item();
    item.id = id;
    item.reference = res["reference"];
    item.designation = res["designation"];
    item.code = res["code"];
    item.family = res["family"];
    item.num = res["num"];
    item.sellingPrice = res["sellingPrice"];
    item.buyingPrice = res["buyingPrice"];
    item.inStock = res["inStock"];
    item.extension = res["extension"];
    item.image = res["image"] == null?AssetImage('images/inventory.jpg'):MemoryImage(res["image"]);
    item.uniqueId = res["uniqueId"];
    return item;
  }
  static bool showBuyingPrice(User user) => user.isNormal() && user.normalRole() == NormalRole.Admin;
}