import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jc_messenger/chatbox.dart';
import 'package:jc_messenger/progress.dart';

import 'home.dart';
import 'models/chats.dart';
import 'models/exit.dart';
import 'models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class Inbox extends StatefulWidget {
  final Muser user;

  const Inbox({super.key, required this.user});
  @override
  // ignore: library_private_types_in_public_api
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  bool isLoading = true;

  List<DocumentSnapshot> ds = [];
  List<Chats> ch = [];
  List<Chats> chp = [];
  List<String> id = [];
  int check = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    gettexts();
    timer =
        Timer.periodic(const Duration(seconds: 5), (Timer t) => gettexts1());
  }

  gettexts1() async {
    setState(() {
      ds = [];
      chp = [];
      id = [];
      check = 0;
    });

    QuerySnapshot snapshot3 = await mref
        .doc(widget.user.id)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    snapshot3.docs.forEach((d) {
      Chats x = Chats.fromDocument(d);

      setState(() {
        if (x.recieverId != widget.user.id) {
          if (!id.contains(x.recieverId)) {
            id.add(x.recieverId);
            chp.add(x);
          }
        } else {
          if (!id.contains(x.senderId)) {
            id.add(x.senderId);
            chp.add(x);
          }
        }
      });
    });

    setState(() {
      ch = chp;
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed

    super.dispose();
  }

  gettexts() async {
    setState(() {
      isLoading = true;
      ds = [];
      ch = [];
      id = [];
      check = 0;
    });

    QuerySnapshot snapshot3 = await mref
        .doc(widget.user.id)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    if (snapshot3.docs.isEmpty) {
      setState(() {
        isLoading = false;
      });
    }

    snapshot3.docs.forEach((d) {
      Chats x = Chats.fromDocument(d);

      setState(() {
        if (x.recieverId != widget.user.id) {
          if (!id.contains(x.recieverId)) {
            id.add(x.recieverId);
            ch.add(x);
          }
        } else {
          if (!id.contains(x.senderId)) {
            id.add(x.senderId);
            ch.add(x);
          }
        }
      });

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          exitButton(context);
          return Future(() => false);
        },
        child: Scaffold(
            backgroundColor: _getColorFromHex("#4A72B6"),
            body: (isLoading)
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline,
                        size: 300,
                        color: Colors.black,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          "YOUR INBOX IS LOADING....",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Bangers",
                              fontSize: 45.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      circularProgress()
                    ],
                  ))
                : (ch.isEmpty)
                    ? const Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            size: 300,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              "NO CONVERSATIONS!!!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Bangers",
                                  fontSize: 45.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ))
                    : RefreshIndicator(
                        onRefresh: () {
                          gettexts();
                          return Future(() => false);
                        },
                        child: Scaffold(
                            backgroundColor: _getColorFromHex("#4A72B6"),
                            body: list()))));
  }

  list() {
    return ListView(
        children: List.generate(
      ch.length,
      (index) {
        return Column(
          children: <Widget>[
            ListTile(
              onTap: () {
                try {
                  showChat(context,
                      name: (widget.user.displayName == ch[index].recieverName)
                          ? ch[index].senderName
                          : ch[index].recieverName,
                      uid: widget.user.id,
                      profileId: (widget.user.id == ch[index].recieverId)
                          ? ch[index].senderId
                          : ch[index].recieverId);
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            backgroundColor: _getColorFromHex("#4A72B6"),
                            title: const Text("Try Again",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Anton",
                                    fontSize: 20.0,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            content: Text("Your messages are reloading\n$e",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
                          ));
                }
              },
              leading: CircleAvatar(
                  radius: 27.5,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: (widget.user.photoUrl ==
                            ch[index].senderPhoto)
                        ? CachedNetworkImageProvider(ch[index].recieverPhoto)
                        : CachedNetworkImageProvider(ch[index].senderPhoto),
                  )),
              title: (widget.user.displayName == ch[index].recieverName)
                  ? (Text(
                      (ch[index].recieverId == ch[index].senderId)
                          ? "Yourself"
                          : ch[index].senderName,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          // fontFamily: "Anton",
                          fontSize: 17),
                    ))
                  : (Text(
                      ch[index].recieverName,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          // fontFamily: "Anton",
                          fontSize: 17),
                    )),
              subtitle: (widget.user.displayName == ch[index].recieverName)
                  ? (Text(
                      "Recieved ${timeago.format(ch[index].timestamp.toDate())}",
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontWeight: FontWeight.w400,
                          fontSize: 15),
                    ))
                  : (Text(
                      "Sent ${timeago.format(ch[index].timestamp.toDate())}",
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontWeight: FontWeight.w400,
                          fontSize: 15),
                    )),
              trailing: (ch[index].isSeen == false)
                  ? Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                        onPressed: null,
                        child: const Text(
                          "NEW",
                          style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ))
                  : const SizedBox(
                      height: 0,
                      width: 0,
                    ),
            ),
            Divider(
              height: 0,
              thickness: 1,
              color: Colors.grey[900],
            )
          ],
        );
      },
    ));
  }
}

showChat(BuildContext context,
    {required String name, required String profileId, required String uid}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Chat(name: name, chatId: profileId, proid: uid),
    ),
  );
}

String funny1(String x) {
  late String a, b, c;
  int q;

  a = x.substring(11, 16);
  int p = int.parse(a.substring(0, 2));
  if (p == 0) {
    p += 12;
    a = "${String.fromCharCode(p)}${x.substring(13, 16)} AM";
  } else if (p >= 1 && p <= 11) {
    a = "$a AM";
  } else if (p == 12) {
    a = "$a PM";
  } else if (p > 12) {
    p -= 12;
    a = "${String.fromCharCode(p)}${x.substring(13, 16)} PM";
  }

  b = x.substring(2, 4);
  q = int.parse(x.substring(5, 7));

  switch (q) {
    case 1:
      c = "Jan";
      break;
    case 2:
      c = "Feb";
      break;
    case 3:
      c = "Mar";
      break;
    case 4:
      c = "Apr";
      break;
    case 5:
      c = "May";
      break;
    case 6:
      c = "Jun";
      break;
    case 7:
      c = "Jul";
      break;
    case 8:
      c = "Aug";
      break;
    case 9:
      c = "Sep";
      break;
    case 10:
      c = "Oct";
      break;
    case 11:
      c = "Nov";
      break;
    case 12:
      c = "Dec";
      break;
    default:
      break;
  }

  b = "${x.substring(8, 10)}-$c-$b";

  return b;
}

String funny(String x) {
  String a;

  a = x.substring(11, 16);

  int p = int.parse(a.substring(0, 2));

  if (p == 0) {
    p += 12;

    a = "$p${x.substring(13, 16)} AM";
  } else if (p >= 1 && p <= 11) {
    a = "$a AM";
  } else if (p == 12) {
    a = "$a PM";
  } else if (p > 12) {
    p -= 12;

    a = "$p${x.substring(13, 16)} PM";
  }

  return a;
}

_getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";

    return Color(int.parse("0x$hexColor"));
  }

  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
}
