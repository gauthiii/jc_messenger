import 'package:cloud_firestore/cloud_firestore.dart';

class Muser {
  final String id;
  final String email;
  final String photoUrl;
  final String displayName;
  final String stat;
  final String pwd;
  final List<dynamic> ids;
  final Timestamp timestamp;

  Muser(
      {required this.id,
      required this.email,
      required this.photoUrl,
      required this.displayName,
      required this.stat,
      required this.pwd,
      required this.ids,
      required this.timestamp});

  factory Muser.fromDocument(DocumentSnapshot doc) {
    return Muser(
        id: doc['id'],
        email: doc['email'],
        photoUrl: doc['photoUrl'],
        displayName: doc['displayName'],
        stat: doc['stat'],
        pwd: doc['pwd'],
        ids: doc['Ids'],
        timestamp: doc['timestamp']);
  }
}
