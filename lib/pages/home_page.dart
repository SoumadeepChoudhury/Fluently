import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:translator_app/utils/translate.dart';

import '../utils/sql.dart';

const String VERSION = "1.0.0";

createToast(message, context) {
  FToast fToast = FToast();
  fToast.init(context);
  fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      child: Container(
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.sp),
            color: Colors.grey.shade300),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.message_outlined),
            SizedBox(
              width: 2.w,
            ),
            Text(
              message,
              style: TextStyle(fontSize: 15.sp),
            ),
          ],
        ),
      ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController sendText = TextEditingController(text: "");
  int initialScrollOffsetValue = 100;
  ScrollController scrollController =
      ScrollController(initialScrollOffset: 100 * 1000);
  String status = "Online";
  String message = "";
  bool isSentByMe = true;
  bool isAtTop = false;
  List<Widget> myMessageCards = [];
  List<Map<int, String>> messages = [];
  int id = 0;
  bool langTobeChanged = false;
  late String valueChosenForSource = "";
  late String valueChosenForTarget = "";
  final Map<String, String> languagesSource = {
    "en": "English",
    "bn": "Bengali",
    "ben": "Benglish",
    "hi": "Hindi",
    "hen": "Hinglish"
  };
  final Map<String, String> languagesTarget = {
    "en": "English",
    "bn": "Bengali",
    "hi": "Hindi",
  };
  test() async {
    // final id = await SQL.insert_item("Kemon Achho?", 1);
    List<Map<String, dynamic>> data = await SQL.get_items();
    // return data;
    for (int i = 0; i < data.length; i++) {
      id = data[i]['id'];
      myMessageCards.add(MessageCard(
          id: id,
          message: data[i]['message'],
          isSentByMe: data[i]['sentByUser'] == 1 ? true : false));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // List languageHeadings = languages.values.toList();
    void handleClick(String value) async {
      switch (value) {
        case 'Delete All Messages':
          bool isDeleted = await SQL.delete_all();
          if (isDeleted) {
            setState(() {
              createToast("All Messages Deleted", context);
              myMessageCards = [];
            });
          }
        case 'About':
          showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                    title: Text("About "),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              "App Name: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Fluently"),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Description: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(
                                  "Translate effortlessly, communicate fluently."),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Version: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(VERSION),
                          ],
                        )
                      ],
                    ),
                  ));
      }
    }

    if (myMessageCards.isEmpty) {
      test();
    }
    return Material(
      child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: AppBarTitle(status: status),
            elevation: 0,
            toolbarHeight: 80.h,
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black,
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: handleClick,
                itemBuilder: (BuildContext context) {
                  return {'Delete All Messages', 'About'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: myMessageCards.map((e) {
                      return e;
                    }).toList(),
                  ),
                ),
              ),
              TypeSendWidgetMethod(),
              if (langTobeChanged) LanguageSelectionBox()
            ],
          )),
    );
  }

  SizedBox LanguageSelectionBox() {
    return SizedBox(
      height: 150.h,
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Source Language",
                style: TextStyle(fontSize: 18.sp),
              ),
              DropdownButton(
                  hint: const Text("Select Language"),
                  value:
                      valueChosenForSource == "" ? null : valueChosenForSource,
                  items: languagesSource.values.toList().map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newVal) {
                    setState(() {
                      valueChosenForSource = newVal!;
                    });
                  }),
            ],
          ),
          const Icon(Icons.arrow_right_alt),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Target Language",
                style: TextStyle(fontSize: 18.sp),
              ),
              DropdownButton(
                  hint: const Text("Select Language"),
                  value:
                      valueChosenForTarget == "" ? null : valueChosenForTarget,
                  items: languagesTarget.values.toList().map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newVal) {
                    setState(() {
                      valueChosenForTarget = newVal!;
                    });
                  })
            ],
          )
        ],
      )),
    );
  }

  Row TypeSendWidgetMethod() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.sp)),
              child: TextField(
                onChanged: (value) {
                  scrollController
                      .jumpTo(scrollController.position.maxScrollExtent);
                },
                textAlignVertical: TextAlignVertical.center,
                controller: sendText,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            langTobeChanged = !langTobeChanged;
                          });
                        },
                        icon: const Icon(
                          Icons.language,
                        )),
                    suffixIconColor: Colors.black,
                    prefixIconColor: Colors.black,
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isAtTop = !isAtTop;
                          });
                          scrollController.jumpTo(isAtTop
                              ? scrollController.position.minScrollExtent
                              : scrollController.position.maxScrollExtent);
                        },
                        icon: Icon(isAtTop
                            ? Icons.arrow_downward
                            : Icons.arrow_upward)),
                    hintText: "Type Something...",
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.sp),
                    border: InputBorder.none),
              )),
        ),
        MaterialButton(
          minWidth: 0,
          padding: EdgeInsets.all(20.sp),
          onPressed: () async {
            if (valueChosenForSource == "" || valueChosenForTarget == "") {
              createToast("Select Languages properly", context);
            } else if (sendText.text == "") {
              createToast("Type something to send.", context);
            }
            if (sendText.text != "" &&
                valueChosenForSource != "" &&
                valueChosenForTarget != "") {
              id += 1;
              setState(() {
                message = sendText.text;
                isSentByMe = true;
                myMessageCards.add(MessageCard(
                    id: id, isSentByMe: isSentByMe, message: message));
                sendText.text = "";
                status = "typing...";
              });
              await SQL.insert_item(message, isSentByMe ? 1 : 0);
              initialScrollOffsetValue += 1;
              scrollController.animateTo(initialScrollOffsetValue * 1000,
                  duration: const Duration(milliseconds: 20),
                  curve: Curves.ease);
              String result = await translate(
                  message,
                  languagesSource.keys
                      .firstWhere(
                          (e) => languagesSource[e] == valueChosenForSource)
                      .toString(),
                  languagesTarget.keys
                      .firstWhere(
                          (e) => languagesTarget[e] == valueChosenForTarget)
                      .toString());
              id += 1;
              setState(() {
                isSentByMe = false;
                message = result;
                myMessageCards.add(MessageCard(
                    id: id, isSentByMe: isSentByMe, message: message));
                status = "Online";
              });
              await SQL.insert_item(message, isSentByMe ? 1 : 0);
              initialScrollOffsetValue += 1;
              scrollController.animateTo(initialScrollOffsetValue * 1000,
                  duration: const Duration(milliseconds: 20),
                  curve: Curves.ease);
            }
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.send),
        )
      ],
    );
  }
}

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.id,
    required this.isSentByMe,
    required this.message,
  });

  final bool isSentByMe;
  final String message;
  final int id;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('$id'),
      onDismissed: (direction) async {
        await SQL.delete_item(id);
        createToast("Message Deleted", context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w),
        child: Align(
          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Card(
            margin: isSentByMe
                ? EdgeInsets.only(left: 30.w, top: 10.h, bottom: 10.h)
                : EdgeInsets.only(right: 30.w, top: 10.h, bottom: 10.h),
            color: isSentByMe ? Colors.greenAccent : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0.sp)),
            elevation: 8,
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: Text(
                message,
                style: TextStyle(fontSize: 17.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    super.key,
    required this.status,
  });
  final String status;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25.sp,
          backgroundColor: Colors.white,
          foregroundColor: Colors.greenAccent,
          backgroundImage: const AssetImage("assets/myLogo.png"),
        ),
        SizedBox(
          width: 10.w,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fluently",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),
            ),
            Text(
              status,
              style: TextStyle(fontSize: 15.sp),
            )
          ],
        ),
      ],
    );
  }
}
