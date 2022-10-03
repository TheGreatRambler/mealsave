import 'package:flutter/material.dart';
import 'package:mealsave/data/state.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserView extends StatelessWidget {
  final String url;

  BrowserView({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 10),
            Text("Recipe"),
          ],
        ),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
