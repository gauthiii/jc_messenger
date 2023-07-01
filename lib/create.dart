import 'package:flutter/material.dart';

class CreatePwd extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreatePwd> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController text = TextEditingController();
  late String pwd;

  submit() {
    final form = _formKey.currentState;

    if (form!.validate()) {
      setState(() {
        pwd = text.text;
      });
      Navigator.pop(context, pwd);
      fun();
    }
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("YOUR PASSCODE IS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Anton",
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              content: Text(pwd,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Anton",
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900])),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _getColorFromHex("#4A72B6"),
      appBar: AppBar(
        backgroundColor: _getColorFromHex("#4A72B6"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Secure your Account",
            style: TextStyle(color: Colors.black, fontFamily: "Anton")),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    "Create a Passcode",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: TextFormField(
                    style: const TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                        fontFamily: "Anton"),
                    controller: text,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (val) {
                      if (val!.trim().length < 4 || val.isEmpty) {
                        return "Passcode too short";
                      } else if (val.trim().length > 20) {
                        return "Passcode too long";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2)),
                      labelText: "Passcode",
                      labelStyle: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromARGB(255, 37, 36, 36),
                          fontFamily: "Anton"),
                      hintText: "Must be at least 4 digits",
                      hintStyle: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromARGB(255, 37, 36, 36),
                          fontFamily: "Anton"),
                    ),
                  ),
                ),
              ),
              Container(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: InkWell(
                    onTap: submit,
                    child: Container(
                      height: 35.0,
                      width: 200.0,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )),
            ],
          )
        ],
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
