//import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jc_messenger/progress.dart';

import 'home.dart';
import 'models/user.dart';

class Profile extends StatefulWidget {
  final String profileId;

  const Profile({super.key, required this.profileId});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  late Muser user;
  bool _displayNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await musersRef.doc(widget.profileId).get();
    user = Muser.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.stat;
    setState(() {
      isLoading = false;
      _displayNameValid = true;
      _bioValid = true;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
            )),
        TextField(
          controller: displayNameController,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Update Display Name",
            hintStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 15),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2)),
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "About Me",
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
            )),
        TextField(
          controller: bioController,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Update Status",
            hintStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 15),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2)),
            errorText: _bioValid ? null : "Status too long",
          ),
        )
      ],
    );
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: _getColorFromHex("#4A72B6"),
              title: const Text("Profile Updated!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Anton",
                      fontSize: 20.0,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black)),
              content: const Text("Your profile has been updated",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      musersRef.doc(widget.profileId).update({
        "displayName": displayNameController.text,
        "stat": bioController.text,
      });
      getUser();
      fun();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () {
          getUser();
          return Future(() => false);
        },
        child: Scaffold(
          backgroundColor: _getColorFromHex("#4A72B6"),
          appBar: AppBar(
            backgroundColor: _getColorFromHex("#4A72B6"),
            centerTitle: true,
            title: Text(
              "MY PROFILE",
              style: TextStyle(
                  color: _getColorFromHex("#000000"),
                  fontSize: 17,
                  // fontWeight: FontWeight.bold,
                  fontFamily: "Anton"),
            ),
            iconTheme: const IconThemeData(
              size: 25,
              color: Colors.black,
            ),
          ),
          body: isLoading
              ? circularProgress()
              : ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        /*    Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 8.0,
                          ),
                          child: CircleAvatar(
                              radius: 53,
                              backgroundColor: Colors.black,
                              child: GestureDetector(
                                child: CircleAvatar(
                                  radius: 50.0,
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      CachedNetworkImageProvider(user.photoUrl),
                                ),
                                onTap: () {},
                              )),
                        ),*/
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              buildDisplayNameField(),
                              Container(height: 10),
                              buildBioField(),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                          onPressed: updateProfileData,
                          child: const Text(
                            "Update Profile",
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
        ));
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
