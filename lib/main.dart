import 'package:flutter/material.dart';
import 'package:mealsave/views/home.dart';
import 'package:mealsave/views/state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrentState()),
        Provider(create: (context) => PluginAccess()),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MealSave",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.light, //ThemeMode.dark,
      home: HomePage(),
    );
  }
}
