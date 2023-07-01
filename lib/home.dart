import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jc_messenger/inbox.dart';
import 'package:jc_messenger/progress.dart';

import 'create.dart';
import 'editProfile.dart';
import 'main.dart';
import 'models/fid.dart';
import 'models/user.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
//final StorageReference storageRef = FirebaseStorage.instance.ref();
final musersRef = FirebaseFirestore.instance.collection('Musers');
final chatRef = FirebaseFirestore.instance.collection('Chatbox');
final idRef = FirebaseFirestore.instance.collection('Convos');
final mref = FirebaseFirestore.instance.collection('Messages');
final DateTime timestamp = DateTime.now();
late Muser currentUser;
late Fid fid;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  bool isAuth = false;
  bool iconPressed = false;
  bool isSearch = false;
  late String name, email, pid;
  List<Muser> users = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      if (account != null) {
        setState(() {
          isLoading = true;
        });
        handleSignIn(account);
      }
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account.email.isNotEmpty) {
      print('User signed in!: $account');
      await createUserInFirestore();

      setState(() {
        isAuth = true;
        isLoading = false;
        name = account.displayName!;
        email = account.email;
        pid = account.photoUrl!;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  getids() async {
    DocumentSnapshot doc = await idRef.doc(currentUser.id).get();

    if (!doc.exists) {
      idRef.doc(currentUser.id).set({
        "Ids": [],
      });
    }

    setState(() {
      fid = Fid.fromDocument(doc);
    });
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await musersRef.doc(user?.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      // ignore: use_build_context_synchronously
      final pwd = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreatePwd()));

      // 3) get username from create account, use it to make new user document in users collection
      musersRef.doc(user?.id).set({
        "id": user?.id,
        "photoUrl": user?.photoUrl,
        "email": user?.email,
        "displayName": user?.displayName,
        "stat": "(No Status)",
        "pwd": pwd,
        "timestamp": timestamp,
        "Ids": [],
      });

      doc = await musersRef.doc(user?.id).get();
    }

    currentUser = Muser.fromDocument(doc);
    print(currentUser.displayName);

    setState(() {
      isLoading = false;
    });
  }

  login() {
    setState(() {
      isLoading = true;
    });

    googleSignIn.signIn();

    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) {
        setState(() {
          isLoading = true;
        });
        handleSignIn(account);
      }
    }, onError: (err) {
      print('Error signing in: $err');
    });
  }

  logout() {
    googleSignIn.signOut();
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleSearch(x) async {
    setState(() {
      users = [];
    });

    QuerySnapshot snapshot = await musersRef.get();

    setState(() {
      users = snapshot.docs.map((doc) => Muser.fromDocument(doc)).toList();
      users.sort((a, b) => a.displayName.compareTo(b.displayName));

      var y = List.from(users);

      y.forEach((e) {
        if (!e.displayName.toUpperCase().contains(x.toUpperCase())) {
          users.remove(e);
        }
      });
      print(
          "**************************** ${users.length} **********************");
      isSearch = true;
    });
  }

  Widget buildAuthScreen() {
    return Scaffold(
      backgroundColor: _getColorFromHex("#4A72B6"),
      appBar: AppBar(
        backgroundColor: _getColorFromHex("#4A72B6"),
        iconTheme: const IconThemeData(
          size: 35,
          color: Colors.black,
        ),
        title: (iconPressed)
            ? TextFormField(
                autofocus: false,
                style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins-Regular"),
                controller: searchController,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(8),
                  hintText: "Search Contact",
                  hintStyle: TextStyle(
                      fontSize: 13.0,
                      color: Colors.black54,
                      fontFamily: "Poppins-Regular"),
                  filled: false,
                ),
                onChanged: (val) {
                  handleSearch(val.trim());
                },
                onFieldSubmitted: (val) async {
                  handleSearch(val.trim());
                },
              )
            : Text(
                "JC Messenger",
                style: TextStyle(
                    color: _getColorFromHex("#000000"),
                    fontSize: 17,
                    // fontWeight: FontWeight.bold,
                    fontFamily: "Anton"),
              ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (iconPressed == true) isSearch = false;
                  iconPressed = !iconPressed;
                });
              },
              icon: Icon((iconPressed) ? Icons.cancel_outlined : Icons.search,
                  color: Colors.black, size: 30))
        ],
      ),
      body: (isSearch)
          ? WillPopScope(
              onWillPop: () {
                setState(() {
                  isSearch = false;
                });
                return Future(() => false);
              },
              child: (users.length == 0)
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Icon(
                          Icons.error_outline,
                          size: 300,
                          color: Colors.black,
                        )),
                        Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            "USER NOT FOUND!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Bangers",
                                fontSize: 45.0,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                      ],
                    )
                  : ListView(
                      children: List.generate(users.length, (index) {
                      return Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              showChat(context,
                                  name: users[index].displayName,
                                  uid: currentUser.id,
                                  profileId: users[index].id);
                            },
                            leading: CircleAvatar(
                                radius: 27.5,
                                backgroundColor: Colors.black,
                                child: CircleAvatar(
                                  radius: 25.0,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: CachedNetworkImageProvider(
                                      users[index].photoUrl),
                                )),
                            title: (Text(
                              (users[index].id == currentUser.id)
                                  ? "Yourself"
                                  : users[index].displayName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  // fontFamily: "Anton",
                                  fontSize: 17),
                            )),
                            subtitle: (Text(
                              users[index].stat,
                              style: TextStyle(
                                  color: Colors.grey[900],
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15),
                            )),
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                            color: Colors.grey[900],
                          )
                        ],
                      );
                    })))
          : Inbox(user: currentUser),
      drawer: Drawer(
          backgroundColor: _getColorFromHex("#4A72B6"),
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            Container(
                color: Colors.black,
                child: DrawerHeader(
                  padding: EdgeInsets.zero,
                  margin: const EdgeInsets.only(bottom: 0),
                  child: Column(children: [
                    Container(height: 30),
                    Center(
                      child: CircleAvatar(
                          radius: 35,
                          backgroundColor: _getColorFromHex("#4A72B6"),
                          backgroundImage: /*const Text("JC",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: "Knewave")),*/
                              CachedNetworkImageProvider(currentUser.photoUrl)),
                    ),
                    Container(height: 15),
                    Center(
                      child:
                          Text("Hello ${currentUser.displayName.split(" ")[0]}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getColorFromHex("#4A72B6"),
                              )),
                    ),
                  ]),
                )),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(
                              profileId: currentUser.id,
                            )));
              },
              leading: const Icon(
                Icons.edit,
                color: Colors.black,
              ),
              title: const Text(
                "Edit Profile",
                style: TextStyle(
                    //    fontFamily: "RussoOne",
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Divider(
              height: 0,
              thickness: 0.7,
              color: Colors.grey[900],
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = false;
                });
                showDialog(
                    context: context,
                    builder: (context) {
                      Future.delayed(const Duration(milliseconds: 500),
                          () async {
                        Navigator.of(context).pop(true);

                        googleSignIn.signOut();

                        setState(() {
                          isAuth = false;

                          isLoading = false;
                        });

                        await analytics.logEvent(
                          name: "signout_google",
                          parameters: {
                            "button_clicked": "true",
                            "user_email": currentUser.email,
                            "timestamp": DateTime.now().toString(),
                          },
                        );

                        setState(() {
                          isLoading = false;
                        });
                      });
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text("Logging out!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        content: Container(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        ),
                      );
                    });
              },
              leading: const Icon(
                Icons.input,
                color: Colors.black,
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                    //  fontFamily: "RussoOne",
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Divider(
              height: 0,
              thickness: 0.7,
              color: Colors.grey[900],
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = false;
                });
                showDialog(
                    context: context,
                    builder: (context) {
                      Future.delayed(const Duration(milliseconds: 500),
                          () async {
                        Navigator.of(context).pop(true);

                        googleSignIn.signOut();

                        chatRef.doc(currentUser.id).get().then((doc) {
                          if (doc.exists) {
                            doc.reference.delete();
                          }
                        });

                        mref.doc(currentUser.id).get().then((doc) {
                          if (doc.exists) {
                            doc.reference.delete();
                          }
                        });

                        musersRef.doc(currentUser.id).get().then((doc) {
                          if (doc.exists) {
                            doc.reference.delete();
                          }
                        });

                        setState(() {
                          isAuth = false;

                          isLoading = false;
                        });

                        await analytics.logEvent(
                          name: "account_deleted",
                          parameters: {
                            "button_clicked": "true",
                            "user_email": currentUser.email,
                            "timestamp": DateTime.now().toString(),
                          },
                        );

                        setState(() {
                          isLoading = false;
                        });
                      });
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text("Deleting Account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        content: Container(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        ),
                      );
                    });
              },
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.black,
              ),
              title: const Text(
                "Delete Account",
                style: TextStyle(
                    //  fontFamily: "RussoOne",
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Divider(
              height: 0,
              thickness: 0.7,
              color: Colors.grey[900],
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
              },
              leading: const Icon(
                Icons.cancel_outlined,
                color: Colors.black,
              ),
              title: const Text(
                "Exit Menu",
                style: TextStyle(
                    //    fontFamily: "RussoOne",
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Divider(
              height: 0,
              thickness: 0.7,
              color: Colors.grey[900],
            ),
          ])),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      backgroundColor: _getColorFromHex("#4A72B6"),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "JC",
              style: TextStyle(
                  fontFamily: "Knewave",
                  color: Colors.black,
                  fontSize: 200.0,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              "MESSENGER\n",
              style: TextStyle(
                  fontFamily: "Knewave",
                  color: Colors.black,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      backgroundColor: Colors.black,
                    ),
                    child: const Text(
                      "Sign in with Google",
                      style: TextStyle(
                          fontFamily: "RussoOne",
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
            ),
            Container(height: 20),
            (isLoading == true) ? circularProgress() : Container(height: 0)
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
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
