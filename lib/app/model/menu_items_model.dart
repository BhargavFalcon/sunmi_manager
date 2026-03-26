import 'package:get/get.dart';

class ItemMenu {
  bool? success;
  Data? data;

  ItemMenu({this.success, this.data});

  ItemMenu.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
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
        items!.add(Items.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
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
  String? dineInPrice;
  String? pickupPrice;
  String? deliveryPrice;
  Category? category;
  List<Variations>? variations;
  List<ModifierGroups>? modifierGroups;
  int? variationsCount;
  int? modifierGroupsCount;
  Map<String, List<Taxes>>? taxes;
  RxInt quantity = 0.obs;

  String? cartItemId;
  Variations? selectedVariation;
  List<Options>? selectedExtras;
  double? cartTotalPrice;
  String? cartOrderType;
  String? cartNote;
  String? cartNoteDraft;
  bool cartEditingNote = false;
  int? cartKotItemId; // Store kot_item_id for items loaded from existing order

  Items({
    this.id,
    this.itemName,
    this.itemNumber,
    this.description,
    this.imageUrl,
    this.type,
    this.inStock,
    this.dineInPrice,
    this.pickupPrice,
    this.deliveryPrice,
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
    inStock =
        json['in_stock'] is int
            ? json['in_stock']
            : (json['in_stock'] is bool
                ? (json['in_stock'] as bool ? 1 : 0)
                : json['in_stock']);
    dineInPrice = json['dine_in_price']?.toString();
    pickupPrice = json['pickup_price']?.toString();
    deliveryPrice = json['delivery_price']?.toString();
    category =
        json['category'] != null
            ? Category.fromJson(
              json['category'] is Map
                  ? json['category'] as Map<String, dynamic>
                  : (json['category'] is List && json['category'].isNotEmpty
                      ? json['category'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    if (json['variations'] != null) {
      variations = <Variations>[];
      if (json['variations'] is List) {
        json['variations'].forEach((v) {
          variations!.add(Variations.fromJson(v as Map<String, dynamic>));
        });
      } else if (json['variations'] is Map) {
        (json['variations'] as Map).forEach((key, value) {
          if (value is Map) {
            variations!.add(
              Variations.fromJson(value as Map<String, dynamic>),
            );
          }
        });
      }
    }
    if (json['modifier_groups'] != null) {
      modifierGroups = <ModifierGroups>[];
      if (json['modifier_groups'] is List) {
        json['modifier_groups'].forEach((v) {
          modifierGroups!.add(
            ModifierGroups.fromJson(v as Map<String, dynamic>),
          );
        });
      } else if (json['modifier_groups'] is Map) {
        (json['modifier_groups'] as Map).forEach((key, value) {
          if (value is Map) {
            modifierGroups!.add(
              ModifierGroups.fromJson(value as Map<String, dynamic>),
            );
          }
        });
      }
    }
    variationsCount = json['variations_count'];
    modifierGroupsCount = json['modifier_groups_count'];
    if (json['taxes'] != null && json['taxes'] is Map) {
      taxes = <String, List<Taxes>>{};
      (json['taxes'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          taxes![key] =
              value
                  .map((v) => Taxes.fromJson(v as Map<String, dynamic>))
                  .toList();
        }
      });
    }
    quantity = (json['quantity'] as int? ?? 0).obs;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_name'] = itemName;
    data['item_number'] = itemNumber;
    data['description'] = description;
    data['image_url'] = imageUrl;
    data['type'] = type;
    data['in_stock'] = inStock;
    data['dine_in_price'] = dineInPrice;
    data['pickup_price'] = pickupPrice;
    data['delivery_price'] = deliveryPrice;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (modifierGroups != null) {
      data['modifier_groups'] =
          modifierGroups!.map((v) => v.toJson()).toList();
    }
    data['variations_count'] = variationsCount;
    data['modifier_groups_count'] = modifierGroupsCount;
    if (taxes != null) {
      data['taxes'] = taxes!.map(
        (key, value) => MapEntry(key, value.map((v) => v.toJson()).toList()),
      );
    }
    data['quantity'] = quantity.value;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_name'] = categoryName;
    data['type'] = type;
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
    price = json['price']?.toString();
    onlinePrice = json['online_price']?.toString();
    takeAwayPrice = json['take_away_price']?.toString();
    selected = false.obs;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['variation'] = variation;
    data['price'] = price;
    data['online_price'] = onlinePrice;
    data['take_away_price'] = takeAwayPrice;
    data['selected'] = selected.value;
    return data;
  }
}

class ModifierGroups {
  int? id;
  String? name;
  String? description;
  bool? isRequired;
  bool? allowMultipleSelection;
  List<Options>? options;

  ModifierGroups({
    this.id,
    this.name,
    this.description,
    this.isRequired,
    this.allowMultipleSelection,
    this.options,
  });

  ModifierGroups.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    isRequired =
        json['is_required'] is bool
            ? json['is_required']
            : (json['is_required'] is int
                ? (json['is_required'] == 1)
                : json['is_required']);
    allowMultipleSelection =
        json['allow_multiple_selection'] is bool
            ? json['allow_multiple_selection']
            : (json['allow_multiple_selection'] is int
                ? (json['allow_multiple_selection'] == 1)
                : json['allow_multiple_selection']);
    if (json['options'] != null) {
      options = <Options>[];
      if (json['options'] is List) {
        json['options'].forEach((v) {
          options!.add(Options.fromJson(v as Map<String, dynamic>));
        });
      } else if (json['options'] is Map) {
        (json['options'] as Map).forEach((key, value) {
          if (value is Map) {
            options!.add(Options.fromJson(value as Map<String, dynamic>));
          }
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['is_required'] = isRequired;
    data['allow_multiple_selection'] = allowMultipleSelection;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Options {
  int? id;
  String? name;
  String? price;
  String? onlinePrice;
  String? takeAwayPrice;
  int? isAvailable;
  RxBool isSelected = false.obs;

  Options({
    this.id,
    this.name,
    this.price,
    this.onlinePrice,
    this.takeAwayPrice,
    this.isAvailable,
  }) {
    isSelected = false.obs;
  }

  Options.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price']?.toString();
    onlinePrice = json['online_price']?.toString();
    takeAwayPrice = json['take_away_price']?.toString();
    isAvailable =
        json['is_available'] is int
            ? json['is_available']
            : (json['is_available'] is bool
                ? (json['is_available'] as bool ? 1 : 0)
                : json['is_available']);
    isSelected = false.obs;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['online_price'] = onlinePrice;
    data['take_away_price'] = takeAwayPrice;
    data['is_available'] = isAvailable;
    data['is_selected'] = isSelected.value;
    return data;
  }
}

class Taxes {
  int? id;
  String? taxName;
  String? taxPercent;
  String? type;

  Taxes({this.id, this.taxName, this.taxPercent, this.type});

  Taxes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxName = json['tax_name'];
    taxPercent = json['tax_percent']?.toString();
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tax_name'] = taxName;
    data['tax_percent'] = taxPercent;
    data['type'] = type;
    return data;
  }
}

class Meta {
  int? total;
  int? filtered;
  List<dynamic>? filtersApplied;

  Meta({this.total, this.filtered, this.filtersApplied});

  Meta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    filtered = json['filtered'];
    filtersApplied = json['filters_applied'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['filtered'] = filtered;
    data['filters_applied'] = filtersApplied;
    return data;
  }
}
