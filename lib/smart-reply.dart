import 'package:flutter/material.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';

class SmartReplyPage extends StatefulWidget {
  const SmartReplyPage({super.key});

  @override
  State<SmartReplyPage> createState() => _SmartReplyPageState();
}

class _SmartReplyPageState extends State<SmartReplyPage> {
  TextEditingController _sendedTextEditingController = TextEditingController();
  TextEditingController _receivedTextEditingController =
      TextEditingController();

  String suggestions = "Suggestions...";
  late SmartReply smartReply;
  @override
  void initState() {
    // TODO: implement initState
    smartReply = SmartReply();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 17,
                    child: TextField(
                      controller: _sendedTextEditingController,
                      maxLines: 1,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  Flexible(
                      flex: 3,
                      child: IconButton(
                          alignment: Alignment.center,
                          style: IconButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Colors.blue),
                          onPressed: () {
                            smartReply.addMessageToConversationFromLocalUser(
                                _sendedTextEditingController.text,
                                DateTime.now().millisecondsSinceEpoch);
                            _sendedTextEditingController.clear();
                          },
                          icon: Icon(Icons.send, color: Colors.white)))
                ],
              ),
              Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
                child: Text("$suggestions"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 17,
                    child: TextField(
                        controller: _receivedTextEditingController,
                        maxLines: 1,
                        decoration:
                            InputDecoration(border: OutlineInputBorder())),
                  ),
                  Flexible(
                      flex: 3,
                      child: IconButton(
                          style: IconButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Colors.green),
                          alignment: Alignment.center,
                          onPressed: () async {
                            smartReply.addMessageToConversationFromRemoteUser(
                                _sendedTextEditingController.text,
                                DateTime.now().millisecondsSinceEpoch,
                                "userId");
                            _receivedTextEditingController.clear();
                            final responses = await smartReply.suggestReplies();
                            print(
                                "Number of suggestions ${responses.suggestions.length}");
                            for (final suggestion in responses.suggestions) {
                              print("Suggestion: ${suggestion}");
                              suggestions += "$suggestion\n";
                            }
                            setState(() {
                              suggestions;
                            });
                          },
                          icon: Icon(Icons.send, color: Colors.white)))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
