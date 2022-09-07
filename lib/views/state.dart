import 'dart:typed_data';
import 'dart:developer';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:fling_units/fling_units.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class CurrentState extends ChangeNotifier {
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  List<Recipe> recipes = [];
  List<StoreIngredient> ingredients = [];
  bool hasLoaded = false;

  Future<void> loadDatabase() async {
    if (!hasLoaded) {
      await recipeDatabase.open("recipes.db");
      ingredients = await recipeDatabase.getAllIngredients();
      recipes = await recipeDatabase.getAllRecipes(ingredients);
      hasLoaded = true;
      notifyListeners();
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    await recipeDatabase.insertRecipe(recipe);
    recipes.add(recipe);
    notifyListeners();
  }

  Future<void> addIngredient(StoreIngredient ingredient) async {
    await recipeDatabase.insertIngredient(ingredient);
    ingredient.showEditView = true;
    ingredients.add(ingredient);
    notifyListeners();
  }

  Future<void> removeRecipe(Recipe recipe, bool isNew) async {
    if (!isNew) {
      await recipeDatabase.deleteRecipe(recipe);
    }
    recipes.remove(recipe);
    notifyListeners();
  }

  bool canRemoveIngredient(StoreIngredient ingredient) {
    for (var recipe in recipes) {
      for (var recipeIngredient in recipe.ingredients) {
        if (recipeIngredient.storeIngredient == ingredient) return false;
      }
    }
    return true;
  }

  Future<void> removeIngredient(StoreIngredient ingredient) async {
    await recipeDatabase.deleteIngredient(ingredient);
    ingredients.remove(ingredient);
    notifyListeners();
  }

  Future<void> modifyRecipe(Recipe recipe, bool closeMenu) async {
    if (closeMenu) {
      // Modify database, don't do this by default because it's costly
      await recipeDatabase.updateRecipe(recipe);
    }
    notifyListeners();
  }

  Future<void> modifyIngredient(StoreIngredient ingredient) async {
    await recipeDatabase.updateIngredient(ingredient);
    notifyListeners();
  }

  int numRecipes() {
    return recipes.length;
  }

  int numIngredients() {
    return ingredients.length;
  }

  Recipe recipe(int index) {
    return recipes[index];
  }

  StoreIngredient ingredient(int index) {
    return ingredients[index];
  }

  // Retrieve some common UI elements
  InputDecoration getTextInputDecoration(
      BuildContext context, String hintText) {
    return InputDecoration(
      labelText: hintText,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: const Color.fromARGB(200, 255, 255, 255),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
    );
  }

  InputDecoration getTextInputDecorationNormal(
      BuildContext context, String hintText) {
    return InputDecoration(
      labelText: hintText,
      labelStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            width: 1.0),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            width: 1.0),
      ),
    );
  }

  InputDecoration getDropdownDecoration(BuildContext context, String hintText) {
    return InputDecoration(
      labelText: hintText,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: const Color.fromARGB(200, 255, 255, 255),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
    );
  }
}

class PluginAccess {
  CameraController? rearCamera;
  late Future<void>? rearCameraWait;

  Future<void> loadCamera() async {
    if (rearCamera == null) {
      WidgetsFlutterBinding.ensureInitialized();

      final cameras = await availableCameras();
      rearCamera = CameraController(
        cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
      );

      rearCameraWait = rearCamera?.initialize();
    }
  }

  Future<void> disposeCamera() async {
    await rearCamera?.dispose();
    rearCamera = null;
  }
}

class Recipe {
  int? id = null;
  String name = "";
  int cookMinutes = 0;
  double expectedServings = 0.0;
  List<Ingredient> ingredients = [];
  Uint8List image = getDefaultImage();

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
      "cook_minutes": cookMinutes,
      "thumbnail": image,
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
      cookMinutes: (map["cook_minutes"] ?? 0) as int,
      image: (map["thumbnail"] ?? getDefaultImage()) as Uint8List,
      ingredients: ingredients,
    );
  }

  Recipe.createNew() {
    // Used when adding a new recipe
    Recipe(
      id: null,
      name: "",
      expectedServings: 0,
      cookMinutes: 0,
      image: getDefaultImage(),
      ingredients: <Ingredient>[],
    );
  }

  Recipe({
    this.id,
    required this.name,
    required this.expectedServings,
    required this.cookMinutes,
    required this.image,
    required this.ingredients,
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
    }
    return VolumeType.quart;
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
    }
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
    }
  }

  double convertQuantity(double old, VolumeType newType) {
    if (this == VolumeType.scalar || newType == VolumeType.scalar) {
      return 0.0;
    } else {
      return newType.toQuantity(fromQuantity(old));
    }
  }
}

class Ingredient {
  int? id = null;
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

  static Ingredient fromMap(
      Map<String, Object?> map, StoreIngredient storeIngredientIn) {
    return Ingredient(
      id: (map["_id"] ?? 0) as int,
      volumeType: VolumeTypeConversion.fromPrettyString(
          (map["volume_type"] ?? "Ounces") as String),
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
        return volumeQuantity /
            storeIngredient!.volumeQuantity *
            storeIngredient!.price;
      } else {
        var thisVolume = volumeType.fromQuantity(volumeQuantity);
        var storeVolume = storeIngredient!.volumeType
            .fromQuantity(storeIngredient!.volumeQuantity);
        // Need consistent unit to divide, can't divide units by each other
        // Limitation of fling_units
        var ingredientRatio =
            thisVolume.asVolume(teaspoons) / storeVolume.asVolume(teaspoons);
        return ingredientRatio * storeIngredient!.price;
      }
    } else {
      return 0.0;
    }
  }

  bool isScalar() {
    // Scalar quantities are handled differently, needs a check
    return storeIngredient != null &&
        storeIngredient!.volumeType == VolumeType.scalar;
  }
}

class StoreIngredient {
  int? id = null;
  String name = "";
  VolumeType volumeType = VolumeType.quart;
  double volumeQuantity = 0;
  int price = 0;
  Uint8List image = getDefaultImage();
  // Whether to open edit view in list
  bool showEditView = false;

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
      volumeType: VolumeTypeConversion.fromPrettyString(
          (map["volume_type"] ?? "Ounces") as String),
      volumeQuantity: (map["volume_quantity"] ?? 0.0) as double,
      price: (map["price"] ?? "") as int,
      image: (map["thumbnail"] ?? getDefaultImage()) as Uint8List,
    );
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
  });
}

Uint8List getDefaultImage() {
  var image = img.Image(100, 100);
  image.fill(img.getColor(255, 255, 255));
  return Uint8List.fromList(img.encodePng(image));
}

class RecipeDatabase {
  Database? db = null;

  Future open(String path) async {
    //File(join(await getDatabasesPath(), path)).delete();
    db = await openDatabase(join(await getDatabasesPath(), path), version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
CREATE TABLE IF NOT EXISTS recipes ( 
    _id integer primary key autoincrement, 
    name text not null,
    expected_servings real not null,
    cook_minutes integer not null,
    thumbnail blob not null)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS recipe_ingredients ( 
    _id integer primary key autoincrement,
    recipe integer not null,
    volume_type text not null,
    volume_quantity real not null,
    store_ingredient integer not null)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS store_ingredients ( 
    _id integer primary key autoincrement, 
    name text not null,
    volume_type text not null,
    volume_quantity real not null,
    price integer not null,
    thumbnail blob not null)
''');
    }, onOpen: (Database db) async {});
  }

  Future<StoreIngredient> insertIngredient(StoreIngredient ingredient) async {
    ingredient.id = await db?.insert("store_ingredients", ingredient.toMap());
    return ingredient;
  }

  Future<List<StoreIngredient>> getAllIngredients() async {
    List<Map<String, Object?>>? ingredients =
        await db?.query("store_ingredients", columns: [
      "_id",
      "name",
      "volume_type",
      "volume_quantity",
      "price",
      "thumbnail",
    ]);

    return ingredients == null
        ? []
        : ingredients.map((map) => StoreIngredient.fromMap(map)).toList();
  }

  Future<void> deleteIngredient(StoreIngredient ingredient) async {
    await db?.delete("store_ingredients",
        where: "_id = ?", whereArgs: [ingredient.id]);
    // TODO check if anything is using this store ingredient
  }

  Future<void> updateIngredient(StoreIngredient ingredient) async {
    await db?.update("store_ingredients", ingredient.toMap(),
        where: "_id = ?", whereArgs: [ingredient.id]);
  }

  Future<Recipe> insertRecipe(Recipe recipe) async {
    recipe.id = await db?.insert("recipes", recipe.toMap());

    for (var ingredient in recipe.ingredients) {
      var ingredientMap = ingredient.toMap();
      ingredientMap["recipe"] = recipe.id;
      ingredient.id = await db?.insert("recipe_ingredients", ingredientMap);
    }

    return recipe;
  }

  Future<List<Recipe>> getAllRecipes(List<StoreIngredient> ingredients) async {
    List<Map<String, Object?>>? recipes = await db?.query("recipes", columns: [
      "_id",
      "name",
      "expected_servings",
      "cook_minutes",
      "thumbnail",
    ]);

    Map<int, StoreIngredient> ingredientsFromID = <int, StoreIngredient>{};
    for (var ingredient in ingredients) {
      if (ingredient.id != null) {
        ingredientsFromID[ingredient.id!] = ingredient;
      }
    }

    if (recipes == null) {
      return [];
    }

    List<Recipe> returnedRecipes = [];
    for (var recipe in recipes) {
      List<Map<String, Object?>>? recipeIngredients =
          await db?.query("recipe_ingredients",
              columns: [
                "_id",
                "recipe",
                "volume_type",
                "volume_quantity",
                "store_ingredient",
              ],
              where: "recipe = ?",
              whereArgs: [recipe["_id"] as int]);

      if (recipeIngredients != null) {
        var ingredients = recipeIngredients
            .map((map) => Ingredient.fromMap(
                map,
                ingredientsFromID[map["store_ingredient"] as int] ??
                    StoreIngredient.createNew()))
            .toList();
        returnedRecipes.add(Recipe.fromMap(recipe, ingredients));
      } else {
        returnedRecipes.add(Recipe.fromMap(recipe, []));
      }
    }

    return returnedRecipes;
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    await db?.delete("recipes", where: "_id = ?", whereArgs: [recipe.id]);
    await db?.delete("recipe_ingredients",
        where: "recipe = ?", whereArgs: [recipe.id]);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await db?.update("recipes", recipe.toMap(),
        where: "_id = ?", whereArgs: [recipe.id]);

    // Intelligently handle all recipe ingredients
    List<int> includedIngredients = <int>[];
    for (var ingredient in recipe.ingredients) {
      var ingredientMap = ingredient.toMap();
      ingredientMap["recipe"] = recipe.id;
      if (ingredient.id == null) {
        ingredient.id = await db?.insert("recipe_ingredients", ingredientMap);
      } else {
        // Just in case it needs updating
        await db?.update("recipe_ingredients", ingredientMap,
            where: "_id = ?", whereArgs: [ingredient.id]);
      }
      includedIngredients.add(ingredient.id!);
      // Not responsible for store ingredients here
    }

    // Remove unused recipe ingredients
    await db?.delete("recipe_ingredients",
        where: "_id NOT IN (${includedIngredients.join(', ')}) AND recipe = ?",
        whereArgs: [recipe.id]);
  }

  Future close() async => db?.close();
}
