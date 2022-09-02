import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mealsave/views/state.dart';
import 'package:provider/provider.dart';
import 'package:mealsave/views/widgets/take_picture.dart';
import 'package:image/image.dart' as img;

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
          appBar: AppBar(
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
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextFormField(
                          initialValue: recipe.name,
                          decoration: currentState.getTextInputDecorationNormal(
                              context, "Name"),
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
                          height: 20,
                        ),
                        // Use https://stackoverflow.com/a/72651188 to display hint text when zero
                        TextFormField(
                          initialValue: recipe.cookMinutes == 0
                              ? null
                              : recipe.cookMinutes.toString(),
                          decoration: currentState.getTextInputDecorationNormal(
                              context, "Preparation Time (Minutes)"),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return "Not a number";
                            } else if (int.tryParse(value) == 0) {
                              return "Cannot be zero";
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (int.tryParse(value) != null) {
                              setState(() {
                                recipe.cookMinutes = int.parse(value);
                              });
                            }
                          },
                          onChanged: (value) {
                            if (int.tryParse(value) != null) {
                              setState(() {
                                recipe.cookMinutes = int.parse(value);
                              });
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          initialValue: recipe.expectedServings == 0.0
                              ? null
                              : recipe.expectedServings.toString(),
                          decoration: currentState.getTextInputDecorationNormal(
                              context, "Servings Produced"),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null) {
                              return "Not a number";
                            } else if (double.tryParse(value) == 0.0) {
                              return "Cannot be zero";
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (double.tryParse(value) != null) {
                              setState(() {
                                recipe.expectedServings = double.parse(value);
                              });
                            }
                          },
                          onChanged: (value) {
                            if (double.tryParse(value) != null) {
                              setState(() {
                                recipe.expectedServings = double.parse(value);
                              });
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(60)),
                          onPressed: () async {
                            final picture = await Navigator.of(context)
                                .push(PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      CameraView(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ));

                            // Assign picture to ingredient
                            setState(() {
                              recipe.image =
                                  Uint8List.fromList(img.encodePng(picture));
                            });
                          },
                          child: const Text("Picture"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: const Color.fromARGB(255, 255, 107, 107),
                              minimumSize: const Size.fromHeight(60)),
                          onPressed: () {
                            var runAsync = () async {
                              await currentState.removeRecipe(
                                  recipe, newRecipe);
                            }();

                            runAsync.then((value) {
                              Navigator.of(context).pop();
                            });
                          },
                          child: const Text("Delete"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recipe.ingredients.length,
                          itemBuilder: (context, index) {
                            return Column(children: [
                              Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF000000),
                                      style: BorderStyle.solid,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: MemoryImage(recipe
                                              .ingredients[index]
                                              .storeIngredient
                                              ?.image ??
                                          StoreIngredient.createNew().image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DropdownButtonFormField<
                                            StoreIngredient>(
                                          style: const TextStyle(
                                              color: Colors.black),
                                          dropdownColor: Colors.white,
                                          decoration: currentState
                                              .getDropdownDecoration(
                                                  context, "Ingredient"),
                                          value: recipe.ingredients[index]
                                              .storeIngredient,
                                          icon: const Icon(Icons.arrow_downward,
                                              color: Colors.black),
                                          elevation: 16,
                                          validator: (value) {
                                            if (value == null) {
                                              return "No ingredient chosen";
                                            }
                                          },
                                          onChanged: (StoreIngredient? value) {
                                            if (value != null) {
                                              setState(() {
                                                recipe.ingredients[index]
                                                    .storeIngredient = value;
                                              });
                                            }
                                          },
                                          items: currentState.ingredients.map<
                                                  DropdownMenuItem<
                                                      StoreIngredient>>(
                                              (StoreIngredient value) {
                                            return DropdownMenuItem<
                                                StoreIngredient>(
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
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            recipe.ingredients[index]
                                                            .storeIngredient !=
                                                        null &&
                                                    recipe
                                                            .ingredients[index]
                                                            .storeIngredient!
                                                            .volumeType ==
                                                        VolumeType.scalar
                                                ? const SizedBox.shrink()
                                                : Expanded(
                                                    child:
                                                        DropdownButtonFormField<
                                                            VolumeType>(
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      dropdownColor:
                                                          Colors.white,
                                                      decoration: currentState
                                                          .getDropdownDecoration(
                                                              context,
                                                              "Quantity Type"),
                                                      value: recipe
                                                          .ingredients[index]
                                                          .volumeType,
                                                      icon: const Icon(
                                                          Icons.arrow_downward,
                                                          color: Colors.black),
                                                      elevation: 16,
                                                      validator: (value) {
                                                        if (value == null) {
                                                          return "No ingredient chosen";
                                                        }
                                                      },
                                                      onChanged:
                                                          (VolumeType? value) {
                                                        setState(() {
                                                          recipe.ingredients[
                                                                  index]
                                                              .changeType(value ??
                                                                  VolumeType
                                                                      .ounce);
                                                        });
                                                      },
                                                      items: VolumeType.values
                                                          .where((value) =>
                                                              value !=
                                                              VolumeType.scalar)
                                                          .map<
                                                                  DropdownMenuItem<
                                                                      VolumeType>>(
                                                              (VolumeType
                                                                  value) {
                                                        return DropdownMenuItem<
                                                            VolumeType>(
                                                          value: value,
                                                          child: Text(value
                                                              .toPrettyString()),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                            Expanded(
                                              child: TextFormField(
                                                // To get initialValue to update
                                                key: Key(recipe
                                                    .ingredients[index]
                                                    .volumeType
                                                    .toString()),
                                                initialValue: recipe
                                                            .ingredients[index]
                                                            .volumeQuantity ==
                                                        0.0
                                                    ? null
                                                    : recipe.ingredients[index]
                                                        .volumeQuantity
                                                        .toStringAsFixed(2),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                decoration: currentState
                                                    .getTextInputDecoration(
                                                        context, "Quantity"),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty ||
                                                      double.tryParse(value) ==
                                                          null) {
                                                    return "Not a number";
                                                  } else if (double.tryParse(
                                                          value) ==
                                                      0.0) {
                                                    return "Cannot be zero";
                                                  }
                                                },
                                                onFieldSubmitted: (value) {
                                                  if (double.tryParse(value) !=
                                                      null) {
                                                    setState(() {
                                                      recipe.ingredients[index]
                                                              .volumeQuantity =
                                                          double.parse(value);
                                                    });
                                                  }
                                                },
                                                onChanged: (value) {
                                                  if (double.tryParse(value) !=
                                                      null) {
                                                    setState(() {
                                                      recipe.ingredients[index]
                                                              .volumeQuantity =
                                                          double.parse(value);
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: const Color.fromARGB(
                                                  255, 255, 107, 107),
                                              minimumSize:
                                                  const Size.fromHeight(60)),
                                          onPressed: () async {
                                            recipe.ingredients.removeAt(index);
                                            if (!newRecipe) {
                                              await currentState.modifyRecipe(
                                                  recipe, false);
                                            }
                                          },
                                          child: const Text("Delete"),
                                        ),
                                      ])),
                              const SizedBox(
                                height: 20,
                              ),
                            ]);
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(60)),
                          onPressed: () async {
                            if (currentState.ingredients.isNotEmpty) {
                              setState(() {
                                recipe.ingredients.add(Ingredient.createNew());
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
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(60)),
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
                          child: Text(newRecipe ? "Add New Recipe" : "Close"),
                        )
                      ],
                    ),
                  ),
                ],
              ),
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
