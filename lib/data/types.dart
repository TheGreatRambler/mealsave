import 'dart:typed_data';

import 'package:fling_units/fling_units.dart';
import 'package:image/image.dart' as img;

class Recipe {
  int? id;

  String name = "";
  String url = "";
  double expectedServings = 0.0;
  List<Ingredient> ingredients = [];
  Uint8List image = getDefaultImage();
  int? lastSynced;

  int getPricePerServing() {
    // The meat of the entire app
    // Yeah there's a lot of boilerplate to get to this point
    double total = 0.0;
    for (var ingredient in ingredients) {
      total += ingredient.getPrice();
    }
    // Cast down to nearest cent
    return (total / expectedServings).round();
  }

  Map<String, Object?> toMap() {
    var entry = <String, Object?>{
      "name": name,
      "expected_servings": expectedServings,
      "url": url,
      "thumbnail": image,
      "last_synced": lastSynced
    };

    if (id != null) {
      entry["_id"] = id;
    }

    return entry;
  }

  static Recipe fromMap(
    Map<String, Object?> map,
    List<Ingredient> ingredients,
  ) {
    return Recipe(
        id: (map["_id"] ?? 0) as int,
        name: (map["name"] ?? "") as String,
        expectedServings: (map["expected_servings"] ?? 0.0) as double,
        url: (map["url"] ?? "") as String,
        image: (map["thumbnail"] ?? getDefaultImage()) as Uint8List,
        ingredients: ingredients,
        lastSynced: map["last_synced"] as int?);
  }

  Recipe.createNew() {
    // Used when adding a new recipe
    Recipe(
      id: null,
      name: "",
      expectedServings: 0,
      url: "",
      image: getDefaultImage(),
      ingredients: <Ingredient>[],
    );
  }

  Recipe({
    this.id,
    required this.name,
    required this.expectedServings,
    required this.url,
    required this.image,
    required this.ingredients,
    this.lastSynced,
  });
}

enum VolumeType {
  liter,
  teaspoon,
  tablespoon,
  ounce,
  cup,
  pint,
  quart,
  gallon,
  pound, // Mass measurement
  gram, // Mass measurement
  scalar, // Integer amount of an item, cannot be converted to or from other types
  percentage, // Percentage of a store ingredient, works for all types
}

extension VolumeTypeConversion on VolumeType {
  String toPrettyString() {
    switch (this) {
      case VolumeType.liter:
        return "Liters";
      case VolumeType.teaspoon:
        return "Teaspoons";
      case VolumeType.tablespoon:
        return "Tablespoons";
      case VolumeType.ounce:
        return "Ounces";
      case VolumeType.cup:
        return "Cups";
      case VolumeType.pint:
        return "Pints";
      case VolumeType.quart:
        return "Quarts";
      case VolumeType.gallon:
        return "Gallons";
      case VolumeType.pound:
        return "Pounds";
      case VolumeType.gram:
        return "Grams";
      case VolumeType.scalar:
        return "Number";
      case VolumeType.percentage:
        return "Percentage";
    }
  }

  static VolumeType fromPrettyString(String name) {
    switch (name) {
      case "Liters":
        return VolumeType.liter;
      case "Teaspoons":
        return VolumeType.teaspoon;
      case "Tablespoons":
        return VolumeType.tablespoon;
      case "Ounces":
        return VolumeType.ounce;
      case "Cups":
        return VolumeType.cup;
      case "Pints":
        return VolumeType.pint;
      case "Quarts":
        return VolumeType.quart;
      case "Gallons":
        return VolumeType.gallon;
      case "Pounds":
        return VolumeType.pound;
      case "Grams":
        return VolumeType.gram;
      case "Number":
        return VolumeType.scalar;
      case "Percentage":
        return VolumeType.percentage;
      default:
        return VolumeType.quart;
    }
  }

  Volume fromQuantity(double quantity) {
    switch (this) {
      case VolumeType.liter:
        return liters(quantity);
      case VolumeType.teaspoon:
        return teaspoons(quantity);
      case VolumeType.tablespoon:
        return tablespoons(quantity);
      case VolumeType.ounce:
        return fluidOunces(quantity);
      case VolumeType.cup:
        return cups(quantity);
      case VolumeType.pint:
        return pints(quantity);
      case VolumeType.quart:
        return quarts(quantity);
      case VolumeType.gallon:
        return gallons(quantity);
      case VolumeType.pound:
        // Mass to volume measurement, using back of the envelope conversion close to flour
        // TODO detect density from name of store item
        // https://www.inchcalculator.com/convert/pound-to-fluid-ounce/
        return fluidOunces(quantity * 20.0);
      case VolumeType.gram:
        // Mass to volume measurement, using back of the envelope conversion
        // TODO detect density from name of store item
        // https://www.inchcalculator.com/convert/gram-to-teaspoon/
        return teaspoons(quantity * 0.20288);
      case VolumeType.scalar:
        // Doesn't matter as long as we're consistent
        return quarts(quantity);
      case VolumeType.percentage:
        null;
    }

    return quarts(quantity);
  }

  double toQuantity(Volume volume) {
    switch (this) {
      case VolumeType.liter:
        return volume.asVolume(liters);
      case VolumeType.teaspoon:
        return volume.asVolume(teaspoons);
      case VolumeType.tablespoon:
        return volume.asVolume(tablespoons);
      case VolumeType.ounce:
        return volume.asVolume(fluidOunces);
      case VolumeType.cup:
        return volume.asVolume(cups);
      case VolumeType.pint:
        return volume.asVolume(pints);
      case VolumeType.quart:
        return volume.asVolume(quarts);
      case VolumeType.gallon:
        return volume.asVolume(gallons);
      case VolumeType.pound:
        return volume.asVolume(fluidOunces) / 20.0;
      case VolumeType.gram:
        return volume.asVolume(teaspoons) / 0.20288;
      case VolumeType.scalar:
        return volume.asVolume(quarts);
      case VolumeType.percentage:
        null;
    }

    return 0.0;
  }

  double convertQuantity(double old, VolumeType newType) {
    if (this == VolumeType.scalar ||
        newType == VolumeType.scalar ||
        this == VolumeType.percentage ||
        newType == VolumeType.percentage) {
      return 0.0;
    } else {
      return newType.toQuantity(fromQuantity(old));
    }
  }

  String getProperLabel() {
    switch (this) {
      case VolumeType.scalar:
        return "Number";
      case VolumeType.percentage:
        return "Percentage";
      default:
        return "Quantity";
    }
  }
}

class Ingredient {
  int? id;

  VolumeType volumeType = VolumeType.quart;
  double volumeQuantity = 0;
  // To provide consistent price information
  StoreIngredient? storeIngredient;
  // Whether to open edit view in list
  bool showEditView = false;

  Map<String, Object?> toMap() {
    var entry = <String, Object?>{
      "volume_type": volumeType.toPrettyString(),
      "volume_quantity": volumeQuantity,
      "store_ingredient": storeIngredient?.id ?? 0,
    };

    if (id != null) {
      entry["_id"] = id;
    }

    return entry;
  }

  static Ingredient fromMap(Map<String, Object?> map, StoreIngredient storeIngredientIn) {
    return Ingredient(
      id: (map["_id"] ?? 0) as int,
      volumeType: VolumeTypeConversion.fromPrettyString((map["volume_type"] ?? "Ounces") as String),
      volumeQuantity: (map["volume_quantity"] ?? 0.0) as double,
      storeIngredient: storeIngredientIn,
    );
  }

  Ingredient.createNew() {
    Ingredient(
      id: null,
      volumeType: VolumeType.ounce,
      volumeQuantity: 0.0,
      storeIngredient: StoreIngredient.createNew(),
    );
  }

  Ingredient({
    this.id,
    required this.volumeType,
    required this.volumeQuantity,
    required this.storeIngredient,
  });

  void changeType(VolumeType newType) {
    volumeQuantity = volumeType.convertQuantity(volumeQuantity, newType);
    volumeType = newType;
  }

  double getPrice() {
    if (storeIngredient != null) {
      if (storeIngredient!.volumeType == VolumeType.scalar) {
        // Unitless value
        return volumeQuantity / storeIngredient!.volumeQuantity * storeIngredient!.price;
      } else if (volumeType == VolumeType.percentage) {
        // Simply returns a percentage of the store ingredient price
        return volumeQuantity / 100 * storeIngredient!.price;
      } else {
        var thisVolume = volumeType.fromQuantity(volumeQuantity);
        var storeVolume = storeIngredient!.volumeType.fromQuantity(storeIngredient!.volumeQuantity);
        // Need consistent unit to divide, can't divide units by each other
        // Limitation of fling_units
        var ingredientRatio = thisVolume.asVolume(teaspoons) / storeVolume.asVolume(teaspoons);
        return ingredientRatio * storeIngredient!.price;
      }
    } else {
      return 0.0;
    }
  }

  bool isScalar() {
    // Scalar quantities are handled differently, needs a check
    return storeIngredient != null && storeIngredient!.volumeType == VolumeType.scalar;
  }
}

class StoreIngredient {
  int? id;

  String name = "";
  VolumeType volumeType = VolumeType.quart;
  double volumeQuantity = 0;
  int price = 0;
  Uint8List image = getDefaultImage();
  // Whether to open edit view in list
  bool showEditView = false;
  int? lastSynced;

  void changeType(VolumeType newType) {
    if (volumeType == VolumeType.scalar || newType == VolumeType.scalar) {
      volumeQuantity = 1.0;
      volumeType = newType;
    } else {
      volumeQuantity = volumeType.convertQuantity(volumeQuantity, newType);
      volumeType = newType;
    }
  }

  Map<String, Object?> toMap() {
    var entry = <String, Object?>{
      "name": name,
      "volume_type": volumeType.toPrettyString(),
      "volume_quantity": volumeQuantity,
      "price": price,
      "thumbnail": image,
      "last_synced": lastSynced
    };

    if (id != null) {
      entry["_id"] = id;
    }

    return entry;
  }

  static StoreIngredient fromMap(Map<String, Object?> map) {
    return StoreIngredient(
        id: (map["_id"] ?? 0) as int,
        name: (map["name"] ?? "") as String,
        volumeType: VolumeTypeConversion.fromPrettyString((map["volume_type"] ?? "Ounces") as String),
        volumeQuantity: (map["volume_quantity"] ?? 0.0) as double,
        price: (map["price"] ?? "") as int,
        image: (map["thumbnail"] ?? getDefaultImage()) as Uint8List,
        lastSynced: map["last_synced"] as int?);
  }

  StoreIngredient.createNew() {
    StoreIngredient(
      id: null,
      name: "",
      volumeType: VolumeType.ounce,
      volumeQuantity: 0.0,
      price: 0,
      image: getDefaultImage(),
    );
  }

  StoreIngredient({
    this.id,
    required this.name,
    required this.volumeType,
    required this.volumeQuantity,
    required this.price,
    required this.image,
    this.lastSynced,
  });
}

Uint8List getDefaultImage() {
  var image = img.Image(100, 100);
  image.fill(img.getColor(255, 255, 255));
  return Uint8List.fromList(img.encodePng(image));
}

// The result of reading a backup
class BackupRecipe {
  List<StoreIngredient> returnedIngredients;
  List<Recipe> returnedRecipes;

  BackupRecipe({required this.returnedIngredients, required this.returnedRecipes});
}
