import 'package:get/get.dart';

class ItemMenu {
  bool? success;
  Data? data;

  ItemMenu({this.success, this.data});

  ItemMenu.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Items>? items;
  Meta? meta;

  Data({this.items, this.meta});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class Items {
  int? id;
  String? itemName;
  String? itemNumber;
  String? description;
  String? imageUrl;
  String? type;
  int? inStock;
  String? price;
  String? onlinePrice;
  String? takeAwayPrice;
  Category? category;
  List<Variations>? variations;
  List<ModifierGroups>? modifierGroups;
  int? variationsCount;
  int? modifierGroupsCount;
  List<Taxes>? taxes;
  RxInt quantity = 0.obs;

  // Cart specific fields
  String? cartItemId;
  Variations? selectedVariation;
  List<Options>? selectedExtras;
  double? cartTotalPrice;
  String? cartOrderType;
  String? cartNote;
  String? cartNoteDraft;
  bool cartEditingNote = false;

  Items({
    this.id,
    this.itemName,
    this.itemNumber,
    this.description,
    this.imageUrl,
    this.type,
    this.inStock,
    this.price,
    this.onlinePrice,
    this.takeAwayPrice,
    this.category,
    this.variations,
    this.modifierGroups,
    this.variationsCount,
    this.modifierGroupsCount,
    this.taxes,
  }) {
    quantity = 0.obs;
  }

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemName = json['item_name'];
    itemNumber = json['item_number'].toString();
    description = json['description'];
    imageUrl = json['image_url'];
    type = json['type'];
    inStock = json['in_stock'];
    price = json['price'];
    onlinePrice = json['online_price'];
    takeAwayPrice = json['take_away_price'];
    category =
        json['category'] != null
            ? new Category.fromJson(json['category'])
            : null;
    if (json['variations'] != null) {
      variations = <Variations>[];
      json['variations'].forEach((v) {
        variations!.add(new Variations.fromJson(v));
      });
    }
    if (json['modifier_groups'] != null) {
      modifierGroups = <ModifierGroups>[];
      json['modifier_groups'].forEach((v) {
        modifierGroups!.add(new ModifierGroups.fromJson(v));
      });
    }
    variationsCount = json['variations_count'];
    modifierGroupsCount = json['modifier_groups_count'];
    if (json['taxes'] != null) {
      taxes = <Taxes>[];
      json['taxes'].forEach((v) {
        taxes!.add(new Taxes.fromJson(v));
      });
    }
    quantity = (json['quantity'] as int? ?? 0).obs;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['item_name'] = this.itemName;
    data['item_number'] = this.itemNumber;
    data['description'] = this.description;
    data['image_url'] = this.imageUrl;
    data['type'] = this.type;
    data['in_stock'] = this.inStock;
    data['price'] = this.price;
    data['online_price'] = this.onlinePrice;
    data['take_away_price'] = this.takeAwayPrice;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.variations != null) {
      data['variations'] = this.variations!.map((v) => v.toJson()).toList();
    }
    if (this.modifierGroups != null) {
      data['modifier_groups'] =
          this.modifierGroups!.map((v) => v.toJson()).toList();
    }
    data['variations_count'] = this.variationsCount;
    data['modifier_groups_count'] = this.modifierGroupsCount;
    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
    }
    data['quantity'] = this.quantity.value;
    return data;
  }
}

class Category {
  int? id;
  String? categoryName;
  String? type;

  Category({this.id, this.categoryName, this.type});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_name'] = this.categoryName;
    data['type'] = this.type;
    return data;
  }
}

class Variations {
  int? id;
  String? variation;
  String? price;
  String? onlinePrice;
  String? takeAwayPrice;
  RxBool selected = false.obs;

  Variations({
    this.id,
    this.variation,
    this.price,
    this.onlinePrice,
    this.takeAwayPrice,
  }) {
    selected = false.obs;
  }

  Variations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    variation = json['variation'];
    price = json['price'];
    onlinePrice = json['online_price'];
    takeAwayPrice = json['take_away_price'];
    selected = false.obs;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['variation'] = this.variation;
    data['price'] = this.price;
    data['online_price'] = this.onlinePrice;
    data['take_away_price'] = this.takeAwayPrice;
    data['selected'] = this.selected.value;
    return data;
  }
}

class ModifierGroups {
  int? id;
  String? name;
  String? description;
  List<Options>? options;

  ModifierGroups({this.id, this.name, this.description, this.options});

  ModifierGroups.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(new Options.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    if (this.options != null) {
      data['options'] = this.options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Options {
  int? id;
  String? name;
  String? price;
  int? isAvailable;
  RxBool isSelected = false.obs;

  Options({this.id, this.name, this.price, this.isAvailable}) {
    isSelected = false.obs;
  }

  Options.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    isAvailable = json['is_available'];
    isSelected = false.obs;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['is_available'] = this.isAvailable;
    data['is_selected'] = this.isSelected.value;
    return data;
  }
}

class Taxes {
  int? id;
  String? taxName;
  String? taxPercent;

  Taxes({this.id, this.taxName, this.taxPercent});

  Taxes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxName = json['tax_name'];
    taxPercent = json['tax_percent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tax_name'] = this.taxName;
    data['tax_percent'] = this.taxPercent;
    return data;
  }
}

class Meta {
  int? total;
  int? filtered;

  Meta({this.total, this.filtered});

  Meta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    filtered = json['filtered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['filtered'] = this.filtered;
    return data;
  }
}
