import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mealsave/views/widgets/recipe_card.dart';
import 'package:mealsave/views/widgets/modify_recipe.dart';
import 'package:mealsave/views/widgets/modify_ingredients.dart';
import 'package:mealsave/views/state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final List<AppLifecycleState> stateHistory = <AppLifecycleState>[];
  bool isloadingRecipes = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    prepareState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> prepareState() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      CurrentState currentState = Provider.of<CurrentState>(context, listen: false);
      await currentState.loadDatabase();

      PluginAccess pluginAccess = Provider.of<PluginAccess>(context, listen: false);
      await pluginAccess.loadCamera();

      setState(() {
        isloadingRecipes = false;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    stateHistory.add(state);
    if (state == AppLifecycleState.inactive) {
      // Remove camera
      PluginAccess pluginAccess = Provider.of<PluginAccess>(context, listen: false);
      await pluginAccess.disposeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 10),
            Text("Recipes"),
          ],
        ),
      ),
      body: isloadingRecipes
          ? const Center(child: CircularProgressIndicator())
          : Consumer<CurrentState>(
              builder: (context, currentState, child) {
                return currentState.numRecipes() > 0
                    ? ListView.builder(
                        itemCount: currentState.numRecipes(),
                        itemBuilder: (context, index) {
                          return RecipeCard(
                            recipe: currentState.recipe(index),
                          );
                        },
                      )
                    : Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text(
                          "Add recipe to begin",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        SvgPicture.asset("images/logo.svg")
                      ]));
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<CurrentState>(
        builder: (context, currentState, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ModifyIngredientsMenu(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ));
                  },
                  tooltip: "Modify store ingredients",
                  child: const Icon(Icons.sell),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ModifyRecipeMenu(
                        newRecipe: true,
                      ),
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
                  },
                  tooltip: "Add recipe",
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.single.path != null) {
                      var file = File(result.files.single.path!);
                      if (await currentState.loadBackupRecipe(file)) {
                        // Success, return early so the error dialog doesn't appear
                        return;
                      }
                    }

                    // If this was reached, there is an error
                    await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Recipe not loaded"),
                        content: const Text("Loading recipe from backup did not succeed"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: "Load recipe from backup",
                  child: const Icon(Icons.file_open),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
