import 'dart:typed_data';

import 'package:fling_units/fling_units.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:mealsave/views/state.dart';
import 'package:provider/provider.dart';
import 'package:mealsave/views/widgets/take_picture.dart';
import 'package:image/image.dart' as img;
import 'package:mealsave/views/widgets/number_dialog.dart';

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
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
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: formKey,
            child:
                Consumer<CurrentState>(builder: (context, currentState, child) {
              return Column(
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: currentState.numIngredients(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentState.ingredient(index).showEditView =
                                  !currentState.ingredient(index).showEditView;
                            });
                          },
                          child: currentState.ingredient(index).showEditView
                              ? Column(children: [
                                  Container(
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black
                                              : Colors.white,
                                          style: BorderStyle.solid,
                                          width: 1.0,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0)),
                                        image: DecorationImage(
                                          image: MemoryImage(currentState
                                              .ingredient(index)
                                              .image),
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
                                              keyboardType: TextInputType.text,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              decoration: currentState
                                                  .getTextInputDecoration(
                                                      context, "Name"),
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
                                              height: 8.0,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child:
                                                      DropdownButtonFormField<
                                                          VolumeType>(
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                    dropdownColor: Colors.white,
                                                    decoration: currentState
                                                        .getDropdownDecoration(
                                                            context,
                                                            "Quantity Type"),
                                                    value: currentState
                                                        .ingredient(index)
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
                                                        currentState
                                                            .ingredient(index)
                                                            .changeType(value ??
                                                                VolumeType
                                                                    .ounce);
                                                        currentState
                                                            .modifyIngredient(
                                                                currentState
                                                                    .ingredient(
                                                                        index));
                                                      });
                                                    },
                                                    items: VolumeType.values
                                                        .where((value) =>
                                                            value !=
                                                            VolumeType
                                                                .percentage)
                                                        .map<
                                                                DropdownMenuItem<
                                                                    VolumeType>>(
                                                            (VolumeType value) {
                                                      return DropdownMenuItem<
                                                          VolumeType>(
                                                        value: value,
                                                        child: Text(value
                                                            .toPrettyString()),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Expanded(
                                                  child: TextFormField(
                                                    // To get initialValue to update
                                                    key: Key(currentState
                                                        .ingredient(index)
                                                        .volumeQuantity
                                                        .toString()),
                                                    initialValue: currentState
                                                                .ingredient(
                                                                    index)
                                                                .volumeQuantity ==
                                                            0.0
                                                        ? null
                                                        : currentState
                                                            .ingredient(index)
                                                            .volumeQuantity
                                                            .toStringAsFixed(2),
                                                    readOnly: true,
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                    decoration: currentState
                                                        .getTextInputDecoration(
                                                            context,
                                                            currentState
                                                                .ingredient(
                                                                    index)
                                                                .volumeType
                                                                .getProperLabel()),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty ||
                                                          double.tryParse(
                                                                  value) ==
                                                              null) {
                                                        return "Not a number";
                                                      } else if (double
                                                              .tryParse(
                                                                  value) ==
                                                          0.0) {
                                                        return "Cannot be zero";
                                                      }
                                                    },
                                                    onTap: () async {
                                                      var returnedValue =
                                                          await openNumberDialog(
                                                              context,
                                                              0,
                                                              4294967295,
                                                              currentState
                                                                  .ingredient(
                                                                      index)
                                                                  .volumeQuantity,
                                                              Text(currentState
                                                                  .ingredient(
                                                                      index)
                                                                  .volumeType
                                                                  .getProperLabel()));

                                                      if (returnedValue !=
                                                          null) {
                                                        setState(() {
                                                          currentState
                                                                  .ingredient(index)
                                                                  .volumeQuantity =
                                                              returnedValue;
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
                                              height: 8.0,
                                            ),
                                            TextFormField(
                                              key: Key(currentState
                                                  .ingredient(index)
                                                  .price
                                                  .toString()),
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
                                              readOnly: true,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              decoration: currentState
                                                  .getTextInputDecoration(
                                                      context, "Price"),
                                              onTap: () async {
                                                var returnedValue =
                                                    await openNumberDialog(
                                                        context,
                                                        0,
                                                        4294967295,
                                                        currentState
                                                                .ingredient(
                                                                    index)
                                                                .price /
                                                            100.0,
                                                        const Text("Price"));

                                                if (returnedValue != null) {
                                                  setState(() {
                                                    currentState
                                                            .ingredient(index)
                                                            .price =
                                                        (returnedValue * 100.0)
                                                            .floor();
                                                    currentState
                                                        .modifyIngredient(
                                                            currentState
                                                                .ingredient(
                                                                    index));
                                                  });
                                                }
                                              },
                                            ),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            minimumSize: const Size
                                                                    .fromHeight(
                                                                60)),
                                                    onPressed: () async {
                                                      final picture =
                                                          await Navigator.of(
                                                                  context)
                                                              .push(
                                                                  PageRouteBuilder(
                                                        pageBuilder: (context,
                                                                animation,
                                                                secondaryAnimation) =>
                                                            CameraView(),
                                                        transitionsBuilder:
                                                            (context,
                                                                animation,
                                                                secondaryAnimation,
                                                                child) {
                                                          const begin =
                                                              Offset(0.0, 1.0);
                                                          const end =
                                                              Offset.zero;
                                                          const curve =
                                                              Curves.ease;

                                                          var tween = Tween(
                                                                  begin: begin,
                                                                  end: end)
                                                              .chain(CurveTween(
                                                                  curve:
                                                                      curve));

                                                          return SlideTransition(
                                                            position: animation
                                                                .drive(tween),
                                                            child: child,
                                                          );
                                                        },
                                                      ));

                                                      // Assign picture to ingredient
                                                      if (picture != null) {
                                                        setState(() {
                                                          currentState
                                                                  .ingredient(index)
                                                                  .image =
                                                              Uint8List.fromList(
                                                                  img.encodePng(
                                                                      picture));
                                                          currentState
                                                              .modifyIngredient(
                                                                  currentState
                                                                      .ingredient(
                                                                          index));
                                                        });
                                                      }
                                                    },
                                                    child:
                                                        const Text("Picture"),
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Expanded(
                                                    child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          minimumSize: const Size
                                                              .fromHeight(60)),
                                                  onPressed: () async {
                                                    setState(() {
                                                      currentState
                                                          .ingredient(index)
                                                          .showEditView = false;
                                                    });
                                                  },
                                                  child: const Text("Minimize"),
                                                ))
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: const Color.fromARGB(
                                                      255, 255, 107, 107),
                                                  minimumSize:
                                                      const Size.fromHeight(
                                                          60)),
                                              onPressed: () async {
                                                if (currentState
                                                    .canRemoveIngredient(
                                                        currentState.ingredient(
                                                            index))) {
                                                  await currentState
                                                      .removeIngredient(
                                                          currentState
                                                              .ingredient(
                                                                  index));
                                                } else {
                                                  await showDialog<String>(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          "Cannot remove ingredient"),
                                                      content: const Text(
                                                          "One or more recipes use this ingredient, remove this ingredient from those recipes before deleting"),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child:
                                                              const Text("OK"),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text("Delete"),
                                            )
                                          ])),
                                ])
                              : Dismissible(
                                  key: UniqueKey(),
                                  // Only allow dismissing if the ingredient can be deleted
                                  direction: currentState.canRemoveIngredient(
                                          currentState.ingredient(index))
                                      ? DismissDirection.endToStart
                                      : DismissDirection.none,
                                  onDismissed: (_) async {
                                    // Remove ingredient if possible
                                    if (currentState.canRemoveIngredient(
                                        currentState.ingredient(index))) {
                                      await currentState.removeIngredient(
                                          currentState.ingredient(index));
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                        style: BorderStyle.solid,
                                        width: 1.0,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0)),
                                      image: DecorationImage(
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.35),
                                          BlendMode.multiply,
                                        ),
                                        image: MemoryImage(currentState
                                            .ingredient(index)
                                            .image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    child: Center(
                                        child: Text(
                                            currentState.ingredient(index).name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ))),
                                  )));
                    },
                  )),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60)),
                        onPressed: () {
                          setState(() {
                            currentState
                                .addIngredient(StoreIngredient.createNew());
                          });
                        },
                        child: const Text("Add Ingredient"),
                      )),
                      const SizedBox(width: 8.0),
                      Expanded(child: Consumer<CurrentState>(
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
                      }))
                    ],
                  ),
                ],
              );
            })),
      ),
    );
  }
}
