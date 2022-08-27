import 'package:flutter/material.dart';
import 'package:mealsave/views/widgets/recipe_card.dart';
import 'package:mealsave/views/widgets/modify_recipe.dart';
import 'package:mealsave/views/widgets/modify_ingredients.dart';
import 'package:mealsave/views/state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isloadingRecipes = true;

  @override
  void initState() {
    super.initState();
    prepareState();
  }

  Future<void> prepareState() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      CurrentState currentState =
          Provider.of<CurrentState>(context, listen: false);
      await currentState.loadDatabase();

      PluginAccess pluginAccess =
          Provider.of<PluginAccess>(context, listen: false);
      await pluginAccess.loadCamera();

      setState(() {
        isloadingRecipes = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                return ListView.builder(
                  itemCount: currentState.numRecipes(),
                  itemBuilder: (context, index) {
                    return RecipeCard(
                      recipe: currentState.recipe(index),
                    );
                  },
                );
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
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ModifyIngredientsMenu(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0);
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
                  },
                  tooltip: "Modify store ingredients",
                  child: const Icon(Icons.sell),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ModifyRecipeMenu(
                        newRecipe: true,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
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
                  },
                  tooltip: "Add recipe",
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
