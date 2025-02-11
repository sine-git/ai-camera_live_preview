/* import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? image;
  late ImagePicker imagePicker;

  @override
  void initState() {
    // TODO: implement initState
    imagePicker = ImagePicker();
    super.initState();
  }

  chooseImage(ImageSource imageSource) async {
    XFile? selectedImage = await imagePicker.pickImage(source: imageSource);
    if (selectedImage != null) {
      setState(() {
        image = File(selectedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              image == null
                  ? Icon(Icons.image, size: 100)
                  : Image.file(image!!),
              ElevatedButton(
                  onPressed: () {
                    chooseImage(ImageSource.gallery);
                  },
                  onLongPress: () {
                    chooseImage(ImageSource.camera);
                  },
                  child: Text("Choose an image"))
            ],
          ),
          /*  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              image == null
                  ? Icon(Icons.image, size: 100)
                  : Image.file(image!!),
              ElevatedButton(
                  onPressed: () {
                    chooseImage(ImageSource.gallery);
                  },
                  onLongPress: () {
                    chooseImage(ImageSource.camera);
                  },
                  child: Text("Choose an image"))
            ],
          ), */
        ));
  }
}
 */