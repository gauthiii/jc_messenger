import 'package:cloud_firestore/cloud_firestore.dart';

class Fid {
  final List<dynamic> fid;

  Fid({
    required this.fid,
  });

  factory Fid.fromDocument(DocumentSnapshot doc) {
    return Fid(fid: doc['Ids']);
  }
}
