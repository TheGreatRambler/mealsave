import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:mealsave/views/state.dart';
import 'package:mealsave/views/widgets/modify_recipe.dart';

class RecipeCard extends StatelessWidget {
  Recipe recipe;

  RecipeCard({
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        width: MediaQuery.of(context).size.width,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(
                0.0,
                10.0,
              ),
              blurRadius: 10.0,
              spreadRadius: -6.0,
            ),
          ],
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35),
              BlendMode.multiply,
            ),
            image: MemoryImage(recipe.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 19,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.yellow,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Text(Money.fromInt(recipe.getPricePerServing(),
                                code: "USD")
                            .format("#.00S")),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.feed,
                          color: Colors.yellow,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Text(recipe.url
                            .split("/")
                            .where((element) => element.isNotEmpty)
                            .last),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ModifyRecipeMenu(
            newRecipe: false,
            recipe: recipe,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ));
      },
    );
  }
}
