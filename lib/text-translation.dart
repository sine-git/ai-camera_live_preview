import 'package:flutter/material.dart';

class TextTranslationPage extends StatefulWidget {
  const TextTranslationPage({super.key});

  @override
  State<TextTranslationPage> createState() => _TextTranslationPageState();
}

class _TextTranslationPageState extends State<TextTranslationPage> {
  String translation = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Text translation",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Français",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon((Icons.arrow_right)),
                Text(
                  "Anglais",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Type text here...",
                  hintStyle: TextStyle(fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Translate",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      backgroundColor: Colors.purple,
                    ),
                  )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    //  border: Border.all(width: 0.5),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Translated text"), Text("\n $translation")],
                ),
                width: double.infinity,
              ),
            )
          ],
        ),
      ),
    );
  }
}
