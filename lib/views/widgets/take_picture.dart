import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:mealsave/views/state.dart';
import 'package:provider/provider.dart';

class CameraView extends StatelessWidget {
  CameraView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 10),
            Text("Take Picture"),
          ],
        ),
      ),
      body: Consumer<PluginAccess>(builder: (context, pluginAccess, child) {
        return pluginAccess.rearCamera != null
            ? CameraPreview(pluginAccess.rearCamera!)
            : const Center(child: CircularProgressIndicator());
      }),
      floatingActionButton:
          Consumer<PluginAccess>(builder: (context, pluginAccess, child) {
        return FloatingActionButton(
          onPressed: () async {
            try {
              await pluginAccess.loadCamera();
              await pluginAccess.rearCameraWait;
              pluginAccess.rearCamera?.setFlashMode(FlashMode.off);

              pluginAccess.rearCamera?.takePicture().then((image) {
                image.readAsBytes().then((bytes) {
                  var image = img.decodeImage(bytes);
                  if (image != null) {
                    Navigator.of(context).pop(image);
                  }
                });
              });
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
          tooltip: "Take picture",
          child: const Icon(Icons.camera_alt),
        );
      }),
    );
  }
}
