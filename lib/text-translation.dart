import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TextTranslationPage extends StatefulWidget {
  const TextTranslationPage({super.key});

  @override
  State<TextTranslationPage> createState() => _TextTranslationPageState();
}

class _TextTranslationPageState extends State<TextTranslationPage> {
  late ModelManager _modelManager;
  late OnDeviceTranslator _onDeviceTranslator;
  bool isFrenchModelDownloaded = false;
  bool isEnglishModelDownloaded = false;
  String translation = "";
  late LanguageIdentifier _languageIdentifier;
  String identifiedLanguages = "";
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState

    _modelManager = OnDeviceTranslatorModelManager();
    _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.8);
    loadModels();
    super.initState();
  }

  loadModels() async {
    final frenchModal;
    final englishModal;
    if (!isFrenchModelDownloaded) {
      frenchModal =
          await _modelManager.downloadModel(TranslateLanguage.french.bcpCode);
    }
    isFrenchModelDownloaded =
        await _modelManager.isModelDownloaded(TranslateLanguage.french.bcpCode);

    if (!isEnglishModelDownloaded) {
      englishModal =
          await _modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }

    isEnglishModelDownloaded = await _modelManager
        .isModelDownloaded(TranslateLanguage.english.bcpCode);

    if (isEnglishModelDownloaded && isFrenchModelDownloaded) {
      _onDeviceTranslator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.french,
          targetLanguage: TranslateLanguage.english);
    }

    setState(() {
      isFrenchModelDownloaded;
      isEnglishModelDownloaded;
    });
  }

  translateText() async {
    String text = _textEditingController.text;
    print(
        "... isFrenchModelDownloaded $isFrenchModelDownloaded & ... isEnglishModelDownloaded $isEnglishModelDownloaded");
    if (isFrenchModelDownloaded && isEnglishModelDownloaded) {
      print("Text to be translated ${text}");
      translation =
          await _onDeviceTranslator.translateText(_textEditingController.text);
    }
    identifyLanguage(text);
    setState(() {
      translation;
    });
  }

  identifyLanguage(String text) async {
    identifiedLanguages = await _languageIdentifier.identifyLanguage(text);
    print("Identified language is $identifiedLanguages");
    setState(() {
      identifiedLanguages;
    });
    _textEditingController.text =
        "$identifiedLanguages ${_textEditingController.text}";
  }

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
              controller: _textEditingController,
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
                    onPressed: () {
                      translateText();
                    },
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
                  children: [
                    SelectableText("Translated text"),
                    SelectableText("\n $translation")
                  ],
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
