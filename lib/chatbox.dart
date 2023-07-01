import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:jc_messenger/home.dart';
import 'package:jc_messenger/progress.dart';

import 'models/chats.dart';
import 'models/fid.dart';
import 'models/user.dart';
import 'package:uuid/uuid.dart';

class Chat extends StatefulWidget {
  final String name;
  final String chatId;
  final String proid;

  const Chat(
      {super.key,
      required this.name,
      required this.chatId,
      required this.proid});

  @override
  // ignore: library_private_types_in_public_api
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool isLoading = false;
  late Muser user, user2;
  bool isUnlock = false;
  bool isWallpaper = true;
  TextEditingController commentController = TextEditingController();
  String mid = const Uuid().v4();
  final ScrollController _myController = ScrollController();
  TextEditingController sub = TextEditingController();

  String enc1 = "";
  String key1 = "";
  String? imgUrl = "images/w3.png";

  List<Chats> textss = [];

  @override
  void initState() {
    super.initState();
    getdetails();
    changeinbox();
  }

  changeinbox() async {
    QuerySnapshot snapshot = await chatRef
        .doc(widget.proid)
        .collection(widget.chatId)
        .orderBy("timestamp", descending: false)
        .get();

    snapshot.docs.forEach((doc) {
      Chats x = Chats.fromDocument(doc);
      chatRef
          .doc(widget.proid)
          .collection(widget.chatId)
          .doc(x.mid)
          .update({"isSeen": true});
      mref
          .doc(widget.proid)
          .collection("messages")
          .doc(x.mid)
          .update({"isSeen": true});

      chatRef
          .doc(widget.chatId)
          .collection(widget.proid)
          .doc(x.mid)
          .update({"isRecieve": true});
      mref
          .doc(widget.chatId)
          .collection("messages")
          .doc(x.mid)
          .update({"isRecieve": true});
    });
  }

  getdetails() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await musersRef.doc(widget.chatId).get();
    DocumentSnapshot doc2 = await musersRef.doc(widget.proid).get();

    setState(() {
      user = Muser.fromDocument(doc);
      user2 = Muser.fromDocument(doc2);
    });
    setState(() {
      isLoading = false;
    });
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
    print(x);
    a = x.substring(11, 16);
    print(a);
    int p = int.parse(a.substring(0, 2));
    print(p);
    if (p == 0) {
      p += 12;
      print(p);
      a = "$p${x.substring(13, 16)} AM";
    } else if (p >= 1 && p <= 11) {
      a = "$a AM";
    } else if (p == 12) {
      a = "$a PM";
    } else if (p > 12) {
      p -= 12;
      print(p);
      a = "$p${x.substring(13, 16)} PM";
    }

    print(a);
    return a;
  }

  buildtexts() {
    return StreamBuilder(
        stream: chatRef
            .doc(widget.proid)
            .collection(widget.chatId)
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Chats> texts = [];
          snapshot.data!.docs.forEach((doc) {
            Chats y = Chats.fromDocument(doc);
            texts.add(y);
          });
          textss = texts;
          return ListView(
            shrinkWrap: true,
            controller: _myController,
            children: List.generate(
              texts.length,
              (index) {
                return Column(children: [
                  if (index == 0) Container(height: 10),
                  if (index == 0 ||
                      (funny1(texts[index].timestamp.toDate().toString()) !=
                          funny1(
                              texts[index - 1].timestamp.toDate().toString())))
                    Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                          onPressed: null,
                          child: Text(
                            funny1(texts[index].timestamp.toDate().toString()),
                            style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )),
                  ChatBubble(
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      alignment: (widget.proid == texts[index].senderId)
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      clipper: ChatBubbleClipper3(
                          type: (widget.proid == texts[index].senderId)
                              ? BubbleType.sendBubble
                              : BubbleType.receiverBubble),
                      backGroundColor: (widget.proid == texts[index].senderId)
                          ? Colors.white
                          : _getColorFromHex("#1a1a1a"),
                      shadowColor: Colors.transparent,
                      child: InkWell(
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  backgroundColor: Colors.white,
                                  title: const Text(
                                    "OPTIONS",
                                    //  textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontFamily: "Anton"),
                                  ),
                                  children: <Widget>[
                                    SimpleDialogOption(
                                        onPressed: () {
                                          if (currentUser.id ==
                                              texts[index].senderId) {
                                            Navigator.pop(context);
                                            chatRef
                                                .doc(texts[index].senderId)
                                                .collection(
                                                    texts[index].recieverId)
                                                .doc(texts[index].mid)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.delete();
                                              }
                                            });
                                            mref
                                                .doc(texts[index].senderId)
                                                .collection("messages")
                                                .doc(texts[index].mid)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.delete();
                                              }
                                            });
                                            showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: const Text(
                                                        "MESSAGE DELETED",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "Anton"),
                                                      ),
                                                      content: Text(
                                                        "${texts[index].recieverName} can still see your message",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ));
                                          } else {
                                            Navigator.pop(context);
                                            chatRef
                                                .doc(texts[index].recieverId)
                                                .collection(
                                                    texts[index].senderId)
                                                .doc(texts[index].mid)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.delete();
                                              }
                                            });
                                            mref
                                                .doc(texts[index].recieverId)
                                                .collection("messages")
                                                .doc(texts[index].mid)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.delete();
                                              }
                                            });
                                            showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: const Text(
                                                        "MESSAGE DELETED",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "Anton"),
                                                      ),
                                                      content: Text(
                                                        "${texts[index].senderName} can still see this message",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ));
                                          }
                                        },
                                        child: Text(
                                          'Delete Message',
                                          //     textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.red[900],
                                              fontFamily: "Anton"),
                                        )),
                                    SimpleDialogOption(
                                        onPressed: () {
                                          if (currentUser.id ==
                                              texts[index].senderId) {
                                            Navigator.pop(context);
                                            chatRef
                                                .doc(texts[index].senderId)
                                                .collection(
                                                    texts[index].recieverId)
                                                .doc(texts[index].mid)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.delete();
                                              }
                                            });
                                            chatRef
                                                .doc(texts[index].recieverId)
                                                .collection(
                                                    texts[index].senderId)
                                                .doc(texts[index].mid)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.delete();
                                              }
                                            });
                                            mref
                                                .doc(texts[index].senderId)
                                                .collection("messages")
                                                .doc(texts[index].mid)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.delete();
                                              }
                                            });
                                            mref
                                                .doc(texts[index].recieverId)
                                                .collection("messages")
                                                .doc(texts[index].mid)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.delete();
                                              }
                                            });
                                            showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    const AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: Text(
                                                        "MESSAGE UNSENT",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "Anton"),
                                                      ),
                                                    ));
                                          } else {
                                            Navigator.pop(context);
                                            showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    const AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: Text(
                                                        "YOU AIN'T THE SENDER",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "Anton"),
                                                      ),
                                                    ));
                                          }
                                        },
                                        child: Text(
                                          'Unsend Message',
                                          // textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.red[900],
                                              fontFamily: "Anton"),
                                        )),
                                    SimpleDialogOption(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'CANCEL',
                                          // textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontFamily: "Anton"),
                                        )),
                                  ],
                                );
                              });
                        },
                        child: Container(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 4, bottom: 4),
                            constraints: BoxConstraints(
                              minHeight: double.minPositive,
                              maxWidth: MediaQuery.of(context).size.width * 0.6,
                            ),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                        child: Text(
                                            (isUnlock == false)
                                                ? encrypt(texts[index].message)
                                                : texts[index].message,
                                            style: TextStyle(
                                                color: (widget.proid ==
                                                        texts[index].senderId)
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold))),
                                    Container(width: 0)
                                  ]),
                              Container(height: 5),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      funny(texts[index]
                                          .timestamp
                                          .toDate()
                                          .toString()),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: (widget.proid ==
                                                  texts[index].senderId)
                                              ? Colors.black54
                                              : Colors.grey),
                                    ),
                                    (widget.proid == texts[index].senderId)
                                        ? Image.asset("images/read.png",
                                            height: 20,
                                            color: (texts[index].isSeen)
                                                ? Colors.red
                                                : Colors.black54)
                                        : const SizedBox(
                                            height: 0,
                                            width: 0,
                                          )
                                  ])
                            ])),
                      )),
                ]);
              },
            ),
          );
        });
  }

  addToRoom(String a, String b) async {
    List<String> f = [];
    print(a);
    DocumentSnapshot doc = await musersRef.doc(a).get();
    Muser user = Muser.fromDocument(doc);

    if (user.ids.length == 0) {
      setState(() {
        f.add(b);
      });

      musersRef.doc(a).update({"Ids": FieldValue.arrayUnion(f)});
    } else {
      Fid fid = Fid.fromDocument(doc);

      setState(() {
        if (!fid.fid.contains(b)) fid.fid.add(b);
      });

      musersRef.doc(a).update({"Ids": FieldValue.arrayUnion(fid.fid)});
    }
  }

  addcomment() {
    if (commentController.text.isNotEmpty) {
      DateTime ts = DateTime.now();
      //update sender's database
      chatRef.doc(widget.proid).collection(widget.chatId).doc(mid).set({
        "mid": mid,
        "message": commentController.text,
        "senderId": widget.proid,
        "senderName": user2.displayName,
        "recieverId": widget.chatId,
        "senderPhoto": user2.photoUrl,
        "recieverPhoto": user.photoUrl,
        "recieverName": user.displayName,
        "timestamp": ts,
        "isSeen": false,
        "isRecieve": false
      });
      addToRoom(widget.proid, widget.chatId);
      //update reciever's database
      chatRef.doc(widget.chatId).collection(widget.proid).doc(mid).set({
        "mid": mid,
        "message": commentController.text,
        "senderId": widget.proid,
        "senderName": user2.displayName,
        "senderPhoto": user2.photoUrl,
        "recieverId": widget.chatId,
        "recieverPhoto": user.photoUrl,
        "recieverName": user.displayName,
        "timestamp": ts,
        "isSeen": false,
        "isRecieve": false
      });
      addToRoom(widget.chatId, widget.proid);

      mref.doc(widget.proid).collection("messages").doc(mid).set({
        "mid": mid,
        "message": commentController.text,
        "senderId": widget.proid,
        "senderName": user2.displayName,
        "senderPhoto": user2.photoUrl,
        "recieverId": widget.chatId,
        "recieverPhoto": user.photoUrl,
        "recieverName": user.displayName,
        "timestamp": ts,
        "isSeen": false,
        "isRecieve": false
      });

      mref.doc(widget.chatId).collection("messages").doc(mid).set({
        "mid": mid,
        "message": commentController.text,
        "senderId": widget.proid,
        "senderName": user2.displayName,
        "senderPhoto": user2.photoUrl,
        "recieverId": widget.chatId,
        "recieverPhoto": user.photoUrl,
        "recieverName": user.displayName,
        "timestamp": ts,
        "isSeen": false,
        "isRecieve": false
      });

      setState(() {
        mid = const Uuid().v4();
        commentController.text = "";
      });
    }
  }

  String encrypt(String value) {
    int fl, hl, fl1, fl2, hl1, hl2;
    var str = value;
    var str1, str2, str3;
    print(str);

    fl = str.length;
    hl = fl ~/ 2;

    str1 = str.substring(0, hl);
    if (fl % 2 == 0) {
      str2 = str.substring(hl, fl);
    } else {
      str2 = str.substring(hl + 1, fl);
      str3 = str.substring(hl, hl + 1);
    }

    var str4, str5, str6;
    fl1 = str1.length;
    hl1 = fl1 ~/ 2;

    str4 = str1.substring(0, hl1);
    if (fl1 % 2 == 0) {
      str5 = str1.substring(hl1, fl1);
    } else {
      str5 = str1.substring(hl1 + 1, fl1);
      str6 = str1.substring(hl1, hl1 + 1);
    }

    var str7, str8, str9;
    fl2 = str2.length;
    hl2 = fl1 ~/ 2;

    str7 = str2.substring(0, hl2);
    if (fl2 % 2 == 0) {
      str8 = str2.substring(hl2, fl2);
    } else {
      str8 = str2.substring(hl2 + 1, fl2);
      str9 = str2.substring(hl2, hl2 + 1);
    }

    if (fl1 % 2 == 0) {
      str1 = str5.split('').reversed.join() + str4;
    } else {
      str1 = str5.split('').reversed.join() + str6 + str4;
    }

    if (fl2 % 2 == 0) {
      str2 = str8.split('').reversed.join() + str7;
    } else {
      str2 = str8.split('').reversed.join() + str9 + str7;
    }

    if (fl % 2 == 0) {
      str = str2 + str1;
    } else {
      str = str2 + str3 + str1;
    }

    print(str);

    var enc = "";
    var key = "";

    for (int i = 0; i < fl; i++) {
      int d, e, s = 0;
      d = str.codeUnitAt(i);

      while (d > 0) {
        e = d % 10;
        s += e;
        d = d ~/ 10;
      }
      key += "$s-";
      var x;
      x = str.codeUnitAt(i) + ((i + 1) * s);
      x = x % 94;
      x = x + 32;

      enc += String.fromCharCode(x);
    }

    key = key.substring(0, (key.length - 1));
//enc=enc+"\n\nKEY:\n\n"+key;

    enc1 = enc;
    key1 = key;

    return enc + key;
  }

  @override
  Widget build(BuildContext context) {
    Timer(
        const Duration(milliseconds: 200),
        () => _myController.animateTo(_myController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut));

    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        /*   Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignIn(),
            ),
          );*/
        return Future(() => true);
      },
      child: Scaffold(
        backgroundColor: _getColorFromHex("#4A72B6"),
        appBar: AppBar(
            backgroundColor: _getColorFromHex("#4A72B6"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    if (isUnlock == false) {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              actions: [
                                TextButton(
                                  child: Text("UNLOCK",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue[900],
                                          fontFamily: "Anton")),
                                  onPressed: () async {
                                    if (sub.text.trim() == currentUser.pwd) {
                                      setState(() {
                                        isUnlock = true;
                                      });
                                      Navigator.pop(context);

                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return const AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: Text(
                                                  "UNLOCKED",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.black,
                                                      fontFamily: "Anton"),
                                                ));
                                          });
                                    } else {
                                      Navigator.pop(context);
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return const AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: Text(
                                                    "Incorrect Pass Code",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Color.fromRGBO(
                                                            183, 28, 28, 1),
                                                        fontFamily: "Anton")));
                                          });
                                    }

                                    sub.text = "";
                                  },
                                ),
                                TextButton(
                                  child: Text("CANCEL",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red[900],
                                          fontFamily: "Anton")),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    sub.text = "";
                                  },
                                ),
                              ],
                              title: const Text("ENTER PASS CODE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.black,
                                      // fontWeight: FontWeight.bold,
                                      fontFamily: "Anton")),
                              content: SizedBox(
                                height: 120,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextFormField(
                                        controller: sub,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontFamily: "Anton"),
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 2)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 2)),
                                          labelText: "Pass Code",
                                          labelStyle: TextStyle(
                                              fontSize: 15.0,
                                              color: Color.fromRGBO(
                                                  66, 66, 66, 1)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    } else {
                      setState(() {
                        isUnlock = false;
                      });
                    }
                  },
                  child: Icon(
                    (isUnlock == false) ? Icons.lock : Icons.lock_open,
                    color: Colors.black,
                    size: 25,
                  )),
            ],
            iconTheme: const IconThemeData(
              size: 25,
              color: Colors.black,
            ),
            centerTitle: true,
            title: TextButton(
              child: Text(
                  (widget.chatId == currentUser.id)
                      ? "Yourself"
                      : (widget.name.length <= 20)
                          ? widget.name
                          : widget.name.substring(0, 20),
                  style: TextStyle(
                    color: _getColorFromHex("#000000"),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  )),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        backgroundColor: _getColorFromHex("#4A72B6"),
                        title: Column(children: [
                          Center(
                            child: CircleAvatar(
                                radius: 37.5,
                                backgroundColor: Colors.black,
                                child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor:
                                        _getColorFromHex("#4A72B6"),
                                    backgroundImage: /*const Text("JC",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: "Knewave")),*/
                                        CachedNetworkImageProvider(
                                            user.photoUrl))),
                          ),
                          Container(height: 15),
                          Center(
                            child: Text(
                                (user.displayName.length <= 20)
                                    ? user.displayName
                                    : user.displayName.substring(0, 20),
                                style: const TextStyle(
                                  fontSize: 20,
                                  // fontWeight: FontWeight.bold,
                                  fontFamily: "Anton",
                                  color: Colors.black,
                                )),
                          ),
                        ]),
                        content: Text("About User : ${user.stat}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "Anton",
                              color: Colors.black,
                            )),
                      );
                    });
              },
              onLongPress: () {
                /*     Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(profileId: user?.id),
                    ),
                  );*/

                setState(() {
                  isWallpaper = !isWallpaper;
                });
              },
            )),
        body: Container(
            decoration: (isWallpaper == false)
                ? const BoxDecoration()
                : BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imgUrl!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        _getColorFromHex("#4A72B6"),
                        BlendMode.color,
                      ),
                    ),
                  ),
            child: Column(
              children: <Widget>[
                Expanded(
                    child: (isLoading)
                        ? circularProgress()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: buildtexts())),
                Container(
                  color: Colors.grey[900],
                  child: ListTile(
                    title: TextFormField(
                      autofocus: false,
                      onTap: () {
                        Timer(
                            const Duration(milliseconds: 500),
                            () => _myController.jumpTo(
                                _myController.position.maxScrollExtent));
                      },
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                      controller: commentController,
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: _getColorFromHex("#4A72B6"),
                                  width: 2)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: _getColorFromHex("#4A72B6"),
                                  width: 2)),
                          labelText: "Send a text...\n",
                          labelStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.normal)),
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          addcomment();
                        },
                        icon: Icon(
                          Icons.send,
                          size: 30,
                          color: _getColorFromHex("#4A72B6"),
                        )),
                  ),
                ),
              ],
            )),
      ),
    );
  }
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



/*

Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/w1.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: 

              */