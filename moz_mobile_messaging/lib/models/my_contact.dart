import 'package:cloud_firestore/cloud_firestore.dart';

class MyContact {
  final String? phoneNumber;
  final String? name;
  final String? username;
  final String? photoUrl;
  final String? chatId;
  final int? ind;

  MyContact(
      {this.phoneNumber,
      this.name,
      this.username,
      this.photoUrl,
      this.chatId,
      this.ind});

  factory MyContact.fromFireStore(DocumentSnapshot snapshot) {
    var data = snapshot;

    return MyContact(
        phoneNumber: data.get('phoneNumber') ?? snapshot.id,
        name: data.get('name'),
        photoUrl: data.get('photoUrl'),
        username: data.get('username'),
        chatId: data.get('chatId'));
  }

  factory MyContact.fromMap(Map data) {
    return MyContact(
        phoneNumber: data['phoneNumber'],
        name: data['name'],
        photoUrl: data['photoUrl'],
        username: data['username'],
        chatId: data['chatId']);
  }

  @override
  String toString() {
    return "index : ${this.ind}, phoneNumber : ${this.phoneNumber}, "
        "name : ${this.name} photoUrl : ${this.photoUrl}, "
        "chatId : ${this.chatId}, username : ${this.username}";
  }
}
