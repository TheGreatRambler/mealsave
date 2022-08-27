import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:mealsave/views/state.dart';
import 'package:provider/provider.dart';
import 'package:mealsave/views/widgets/take_picture.dart';
import 'package:image/image.dart' as img;

class ModifyIngredientsMenu extends StatefulWidget {
  ModifyIngredientsMenu({
    Key? key,
  }) : super(key: key);

  @override
  _ModifyIngredientsMenuState createState() => _ModifyIngredientsMenuState();
}

class _ModifyIngredientsMenuState extends State<ModifyIngredientsMenu> {
  final GlobalKey<FormState> formKey = GlobalKey();

  _ModifyIngredientsMenuState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 10),
            Text("Modify Store Ingredients"),
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
                  child: Consumer<CurrentState>(
                      builder: (context, currentState, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentState.numIngredients(),
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
                                      image: MemoryImage(
                                          currentState.ingredient(index).image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          initialValue: currentState
                                              .ingredient(index)
                                              .name,
                                          decoration: const InputDecoration(
                                              hintText: "Name",
                                              filled: true,
                                              fillColor: Color.fromARGB(
                                                  200, 255, 255, 255),
                                              border: OutlineInputBorder()),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Cannot be empty";
                                            }
                                          },
                                          onFieldSubmitted: (value) {
                                            setState(() {
                                              currentState
                                                  .ingredient(index)
                                                  .name = value;
                                              currentState.modifyIngredient(
                                                  currentState
                                                      .ingredient(index));
                                            });
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              currentState
                                                  .ingredient(index)
                                                  .name = value;
                                              currentState.modifyIngredient(
                                                  currentState
                                                      .ingredient(index));
                                            });
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  VolumeType>(
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                decoration: InputDecoration(
                                                  hintText: "Quantity Type",
                                                  filled: true,
                                                  fillColor:
                                                      const Color.fromARGB(
                                                          200, 255, 255, 255),
                                                  contentPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 20.0,
                                                          vertical: 18.0),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0)),
                                                ),
                                                value: currentState
                                                    .ingredient(index)
                                                    .volumeType,
                                                icon: const Icon(
                                                    Icons.arrow_downward),
                                                elevation: 16,
                                                onChanged: (VolumeType? value) {
                                                  setState(() {
                                                    currentState
                                                        .ingredient(index)
                                                        .changeType(value ??
                                                            VolumeType.ounce);
                                                    currentState
                                                        .modifyIngredient(
                                                            currentState
                                                                .ingredient(
                                                                    index));
                                                  });
                                                },
                                                items: VolumeType.values.map<
                                                        DropdownMenuItem<
                                                            VolumeType>>(
                                                    (VolumeType value) {
                                                  return DropdownMenuItem<
                                                      VolumeType>(
                                                    value: value,
                                                    child: Text(
                                                        value.toPrettyString()),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                // To get initialValue to update
                                                key: Key(currentState
                                                    .ingredient(index)
                                                    .volumeType
                                                    .toString()),
                                                initialValue: currentState
                                                            .ingredient(index)
                                                            .volumeQuantity ==
                                                        0.0
                                                    ? null
                                                    : currentState
                                                        .ingredient(index)
                                                        .volumeQuantity
                                                        .toStringAsFixed(2),
                                                decoration: const InputDecoration(
                                                    hintText: "Quantity",
                                                    filled: true,
                                                    fillColor: Color.fromARGB(
                                                        200, 255, 255, 255),
                                                    border:
                                                        OutlineInputBorder()),
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
                                                      currentState
                                                              .ingredient(index)
                                                              .volumeQuantity =
                                                          double.parse(value);
                                                      currentState
                                                          .modifyIngredient(
                                                              currentState
                                                                  .ingredient(
                                                                      index));
                                                    });
                                                  }
                                                },
                                                onChanged: (value) {
                                                  if (double.tryParse(value) !=
                                                      null) {
                                                    setState(() {
                                                      currentState
                                                              .ingredient(index)
                                                              .volumeQuantity =
                                                          double.parse(value);
                                                      currentState
                                                          .modifyIngredient(
                                                              currentState
                                                                  .ingredient(
                                                                      index));
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
                                        TextFormField(
                                          initialValue: currentState
                                                      .ingredient(index)
                                                      .price ==
                                                  0
                                              ? null
                                              : Money.fromInt(
                                                      currentState
                                                          .ingredient(index)
                                                          .price,
                                                      code: "USD")
                                                  .format("#.00S"),
                                          decoration: const InputDecoration(
                                              hintText: "Price",
                                              filled: true,
                                              fillColor: Color.fromARGB(
                                                  200, 255, 255, 255),
                                              border: OutlineInputBorder()),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                Money.tryParse(value,
                                                        code: "USD") ==
                                                    null) {
                                              return "Not money";
                                            } else if (Money.parse(value,
                                                        code: "USD")
                                                    .minorUnits
                                                    .toInt() ==
                                                0) {
                                              return "Cannot be zero";
                                            }
                                          },
                                          onFieldSubmitted: (value) {
                                            if (Money.tryParse(value,
                                                    code: "USD") !=
                                                null) {
                                              setState(() {
                                                currentState
                                                    .ingredient(index)
                                                    .price = Money.parse(value,
                                                        code: "USD")
                                                    .minorUnits
                                                    .toInt();
                                                currentState.modifyIngredient(
                                                    currentState
                                                        .ingredient(index));
                                              });
                                            }
                                          },
                                          onChanged: (value) {
                                            if (Money.tryParse(value,
                                                    code: "USD") !=
                                                null) {
                                              setState(() {
                                                currentState
                                                    .ingredient(index)
                                                    .price = Money.parse(value,
                                                        code: "USD")
                                                    .minorUnits
                                                    .toInt();
                                                currentState.modifyIngredient(
                                                    currentState
                                                        .ingredient(index));
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(60)),
                                          onPressed: () async {
                                            final picture =
                                                await Navigator.of(context)
                                                    .push(PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  CameraView(),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(0.0, 1.0);
                                                const end = Offset.zero;
                                                const curve = Curves.ease;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));

                                                return SlideTransition(
                                                  position:
                                                      animation.drive(tween),
                                                  child: child,
                                                );
                                              },
                                            ));

                                            // Assign picture to ingredient
                                            setState(() {
                                              currentState
                                                      .ingredient(index)
                                                      .image =
                                                  Uint8List.fromList(
                                                      img.encodePng(picture));
                                              currentState.modifyIngredient(
                                                  currentState
                                                      .ingredient(index));
                                            });
                                          },
                                          child: const Text("Picture"),
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
                                            await currentState.removeIngredient(
                                                currentState.ingredient(index));
                                          },
                                          child: const Text("Delete"),
                                        )
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
                          onPressed: () {
                            setState(() {
                              currentState
                                  .addIngredient(StoreIngredient.createNew());
                            });
                          },
                          child: const Text("Add Ingredient"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer<CurrentState>(
                            builder: (context, currentState, child) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(60)),
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (formKey.currentState!.validate()) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("Close"),
                          );
                        })
                      ],
                    );
                  })),
            ],
          ),
        ),
      ),
    );
  }
}
