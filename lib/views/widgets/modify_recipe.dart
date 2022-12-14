import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mealsave/data/state.dart';
import 'package:provider/provider.dart';
import 'package:mealsave/views/widgets/take_picture.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:mealsave/views/widgets/number_dialog.dart';
import 'package:mealsave/views/widgets/open_browser.dart';
import 'package:mealsave/data/types.dart';

class ModifyRecipeMenu extends StatefulWidget {
  Recipe? recipe;
  bool newRecipe;
  ModifyRecipeMenu({
    required this.newRecipe,
    this.recipe,
    Key? key,
  }) : super(key: key);

  @override
  _ModifyRecipeMenuState createState() => _ModifyRecipeMenuState(
        newRecipe: this.newRecipe,
        recipe: this.recipe ?? Recipe.createNew(),
      );
}

class _ModifyRecipeMenuState extends State<ModifyRecipeMenu> {
  final GlobalKey<FormState> formKey = GlobalKey();
  Recipe recipe;
  bool newRecipe;

  _ModifyRecipeMenuState({
    required this.newRecipe,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentState>(builder: (context, currentState, child) {
      return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu),
                const SizedBox(width: 10),
                Text(newRecipe ? "Add New Recipe" : "Modify Recipe"),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                        initialValue: recipe.name,
                        keyboardType: TextInputType.text,
                        decoration: currentState.getTextInputDecorationNormal(context, "Name"),
                        onFieldSubmitted: (value) {
                          setState(() {
                            recipe.name = value;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            recipe.name = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Cannot be empty";
                          }
                        },
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            initialValue: recipe.url,
                            keyboardType: TextInputType.text,
                            decoration: currentState.getURLDecoration(context, "URL", () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => BrowserView(url: recipe.url),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ));
                            }),
                            onFieldSubmitted: (value) {
                              setState(() {
                                recipe.url = value;
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                recipe.url = value;
                              });
                            },
                            validator: (value) {
                              return null;
                            },
                          )),
                          const SizedBox(width: 8.0),
                          Expanded(
                              child: TextFormField(
                            key: Key(recipe.expectedServings.toString()),
                            initialValue: recipe.expectedServings == 0.0 ? null : recipe.expectedServings.toString(),
                            readOnly: true,
                            decoration: currentState.getTextInputDecorationNormal(context, "Servings Produced"),
                            validator: (value) {
                              if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                return "Not a number";
                              } else if (double.tryParse(value) == 0.0) {
                                return "Cannot be zero";
                              }
                            },
                            onTap: () async {
                              var returnedValue = await openNumberDialog(
                                  context, 0, 4294967295, recipe.expectedServings, const Text("Servings Produced"));

                              if (returnedValue != null) {
                                setState(() {
                                  recipe.expectedServings = returnedValue;
                                });
                              }
                            },
                          ))
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                            onPressed: () async {
                              final picture = await Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => CameraView(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ));

                              // Assign picture to ingredient
                              if (picture != null) {
                                setState(() {
                                  recipe.image = Uint8List.fromList(img.encodePng(picture));
                                  currentState.server.attemptUploadRecipeImage(recipe);
                                });
                              }
                            },
                            child: const Text("Picture"),
                          )),
                          const SizedBox(width: 8.0),
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                            onPressed: () async {
                              var name = await currentState.backupRecipe(recipe);
                              if (name != null) {
                                await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: const Text("Recipe saved"),
                                    content: Text("Saved to $name"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: const Text("Error"),
                                    content: const Text("Recipe not saved"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: const Text("Backup"),
                          )),
                          const SizedBox(width: 8.0),
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: const Color.fromARGB(255, 255, 107, 107),
                                minimumSize: const Size.fromHeight(60)),
                            onPressed: () {
                              var runAsync = () async {
                                await currentState.removeRecipe(recipe, newRecipe);
                              }();

                              runAsync.then((value) {
                                Navigator.of(context).pop();
                              });
                            },
                            child: const Text("Delete"),
                          ))
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Expanded(
                          child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  recipe.ingredients[index].showEditView = !recipe.ingredients[index].showEditView;
                                });
                              },
                              child: recipe.ingredients[index].showEditView
                                  ? Column(children: [
                                      Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                              style: BorderStyle.solid,
                                              width: 1.0,
                                            ),
                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                            image: DecorationImage(
                                              image: MemoryImage(recipe.ingredients[index].storeIngredient?.image ??
                                                  StoreIngredient.createNew().image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                DropdownButtonFormField<StoreIngredient>(
                                                  style: const TextStyle(color: Colors.black),
                                                  dropdownColor: Colors.white,
                                                  decoration: currentState.getDropdownDecoration(context, "Ingredient"),
                                                  value: recipe.ingredients[index].storeIngredient,
                                                  icon: const Icon(Icons.arrow_downward, color: Colors.black),
                                                  elevation: 16,
                                                  validator: (value) {
                                                    if (value == null) {
                                                      return "No ingredient chosen";
                                                    }
                                                  },
                                                  onChanged: (StoreIngredient? value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        recipe.ingredients[index].storeIngredient = value;
                                                      });
                                                    }
                                                  },
                                                  items: currentState.ingredients
                                                      .map<DropdownMenuItem<StoreIngredient>>((StoreIngredient value) {
                                                    return DropdownMenuItem<StoreIngredient>(
                                                      value: value,
                                                      child: Text(
                                                        value.name,
                                                        style: const TextStyle(
                                                          fontSize: 19,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                                const SizedBox(
                                                  height: 8.0,
                                                ),
                                                Row(
                                                  children: [
                                                    recipe.ingredients[index].isScalar()
                                                        ? const SizedBox.shrink()
                                                        : Expanded(
                                                            child: DropdownButtonFormField<VolumeType>(
                                                              style: const TextStyle(color: Colors.black),
                                                              dropdownColor: Colors.white,
                                                              decoration: currentState.getDropdownDecoration(
                                                                  context, "Quantity Type"),
                                                              value: recipe.ingredients[index].volumeType,
                                                              icon:
                                                                  const Icon(Icons.arrow_downward, color: Colors.black),
                                                              elevation: 16,
                                                              validator: (value) {
                                                                if (value == null) {
                                                                  return "No ingredient chosen";
                                                                }
                                                              },
                                                              onChanged: (VolumeType? value) {
                                                                setState(() {
                                                                  recipe.ingredients[index]
                                                                      .changeType(value ?? VolumeType.ounce);
                                                                });
                                                              },
                                                              items: VolumeType.values
                                                                  .where((value) => value != VolumeType.scalar)
                                                                  .map<DropdownMenuItem<VolumeType>>(
                                                                      (VolumeType value) {
                                                                return DropdownMenuItem<VolumeType>(
                                                                  value: value,
                                                                  child: Text(value.toPrettyString()),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                    recipe.ingredients[index].isScalar()
                                                        ? const SizedBox.shrink()
                                                        : const SizedBox(width: 8.0),
                                                    Expanded(
                                                      child: TextFormField(
                                                        // To get initialValue to update
                                                        key: Key(recipe.ingredients[index].volumeQuantity.toString()),
                                                        initialValue: recipe.ingredients[index].volumeQuantity == 0.0
                                                            ? null
                                                            : recipe.ingredients[index].volumeQuantity
                                                                .toStringAsFixed(2),
                                                        readOnly: true,
                                                        style: const TextStyle(color: Colors.black),
                                                        decoration: currentState.getTextInputDecoration(context,
                                                            recipe.ingredients[index].volumeType.getProperLabel()),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty ||
                                                              double.tryParse(value) == null) {
                                                            return "Not a number";
                                                          } else if (double.tryParse(value) == 0.0) {
                                                            return "Cannot be zero";
                                                          }
                                                        },
                                                        onTap: () async {
                                                          var returnedValue = await openNumberDialog(
                                                              context,
                                                              0,
                                                              4294967295,
                                                              recipe.ingredients[index].volumeQuantity,
                                                              Text(recipe.ingredients[index].volumeType
                                                                  .getProperLabel()));

                                                          if (returnedValue != null) {
                                                            setState(() {
                                                              recipe.ingredients[index].volumeQuantity = returnedValue;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 8.0,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          minimumSize: const Size.fromHeight(60)),
                                                      onPressed: () async {
                                                        setState(() {
                                                          recipe.ingredients[index].showEditView = false;
                                                        });
                                                      },
                                                      child: const Text("Minimize"),
                                                    )),
                                                    const SizedBox(width: 8.0),
                                                    Expanded(
                                                        child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          primary: const Color.fromARGB(255, 255, 107, 107),
                                                          minimumSize: const Size.fromHeight(60)),
                                                      onPressed: () async {
                                                        recipe.ingredients.removeAt(index);
                                                        if (!newRecipe) {
                                                          await currentState.modifyRecipe(recipe, false);
                                                        }
                                                      },
                                                      child: const Text("Delete"),
                                                    ))
                                                  ],
                                                ),
                                              ])),
                                    ])
                                  : Dismissible(
                                      key: UniqueKey(),
                                      direction: DismissDirection.startToEnd,
                                      onDismissed: (_) async {
                                        recipe.ingredients.removeAt(index);
                                        if (!newRecipe) {
                                          await currentState.modifyRecipe(recipe, false);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? Colors.black
                                                : Colors.white,
                                            style: BorderStyle.solid,
                                            width: 1.0,
                                          ),
                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                          image: DecorationImage(
                                            colorFilter: ColorFilter.mode(
                                              Colors.black.withOpacity(0.35),
                                              BlendMode.multiply,
                                            ),
                                            image: MemoryImage(recipe.ingredients[index].storeIngredient?.image ??
                                                StoreIngredient.createNew().image),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        width: MediaQuery.of(context).size.width,
                                        height: 60,
                                        child: Center(
                                            child: Text(recipe.ingredients[index].storeIngredient?.name ?? "",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ))),
                                      ),
                                    ));
                        },
                      )),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                              onPressed: () async {
                                if (currentState.ingredients.isNotEmpty) {
                                  setState(() {
                                    var newIngredient = Ingredient.createNew();
                                    newIngredient.showEditView = true;
                                    recipe.ingredients.add(newIngredient);
                                  });
                                } else {
                                  await showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text("Cannot add ingredient"),
                                      content: const Text(
                                          "Must create at least 1 store ingredient to add a recipe ingredient"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: const Text("Add Ingredient"),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                            onPressed: () {
                              var runAsync = () async {
                                if (formKey.currentState!.validate()) {
                                  if (newRecipe) {
                                    // Add to existing recipes
                                    await currentState.addRecipe(recipe);
                                  } else {
                                    await currentState.modifyRecipe(recipe, true);
                                  }
                                  return true;
                                } else {
                                  return false;
                                }
                              }();

                              runAsync.then((valid) {
                                if (valid) {
                                  Navigator.of(context).pop();
                                }
                              });
                            },
                            child: const Text("Finished"),
                          ))
                        ],
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (!newRecipe && formKey.currentState!.validate()) {
            await currentState.modifyRecipe(recipe, true);
          }
          return true;
        },
      );
    });
  }
}
