import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../config/Constants.dart';
import '../../../config/Paths.dart';
import '../../../core/abstract/base_functions.dart';
import '../../../utils/SharedObjects.dart';
import '../../chat/utils/chat_function.dart';
import '../../local_db/utils/db_manager.dart';
import '../../mqtt/state_provider/mqtt_state.dart';
import '../../mqtt/utils/mqtt_manager.dart';

class AddFriendsFunction extends BaseAddFriendsFunction {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ChatFunction chatFunction = ChatFunction();
  String? uid = SharedObjects.prefs.getString(Constants.sessionUid);

  @override
  void dispose() {}

  @override
  Future<void> addToFriendRequestsCollection(String phoneNumber) async {
    // add to friend requests collection of the other user
    CollectionReference usersRef = _firestore.collection(Paths.usersPath);

    // first get my data
    DocumentSnapshot snapshot = await usersRef.doc(uid).get();

    usersRef
        .doc(phoneNumber)
        .collection(Paths.friendRequestsPath)
        .doc(uid)
        .set({
      'username': snapshot.get('username'),
      'photoUrl': snapshot.get('photoUrl'),
      'name': snapshot.get('name'),
      'phoneNumber': snapshot.get('phoneNumber'),
    });
  }

  @override
  Future<String> addToLocalDBAndSubscribe(
      BuildContext context, String phoneNumber) async {
    DocumentSnapshot docSnapshot = await _firestore
        .collection(Paths.usersPath)
        .doc(phoneNumber)
        .get();

    String chatId = await chatFunction.createChatIdForContact(phoneNumber);

    // create a row for this user, i.e add the contact to my local db
    String photoUrl = docSnapshot.get('photoUrl');
    String username = docSnapshot.get('username');
    String name = docSnapshot.get('name');
    await DBManager.db.createRow(phoneNumber, chatId, name, username, photoUrl,
        0); // 0 because here this is not a phone contact

    // Subscribe to the chatId
    MQTTManager? manager = context.read<MQTTState>().manager;
    print("SUBSCRIBING TO TOPIC : $chatId");
    manager!.subscribeTopic(chatId);

    return chatId;
  }

  @override
  Future<void> addToSentRequestsCollection(String phoneNumber) async {
    // add to my sent requests collection
    CollectionReference usersRef = _firestore.collection(Paths.usersPath);

    // first get the data for the phoneNumber
    DocumentSnapshot snapshot = await usersRef.doc(phoneNumber).get();

    usersRef
        .doc(uid)
        .collection(Paths.sentRequestsPath)
        .doc(phoneNumber)
        .set({
      'username': snapshot.get('username'),
      'photoUrl': snapshot.get('photoUrl'),
      'name': snapshot.get('name'),
      'phoneNumber': snapshot.get('phoneNumber'),
    });
  }

  @override
  Future<MozIdLocation> checkHitUpId(String hitUpId) async {
    bool ans;
    // check if hitUpId exists in local db
    ans = await DBManager.db.checkIfUsernameExistsInDb(hitUpId);

    if (ans) {
      return MozIdLocation.InLocalDb;
    } else {
      // check if hitUpId exists in Firebase Friend Requests collection
      String? uid = SharedObjects.prefs.getString(Constants.sessionUid);
      QuerySnapshot snapshot = await _firestore
          .collection(Paths.usersPath)
          .doc(uid)
          .collection(Paths.friendRequestsPath)
          .where('username', isEqualTo: hitUpId)
          .limit(1)
          .get();

      if (snapshot.docs.length > 0) {
        return MozIdLocation.InFriendRequests;
      } else {
        // check if hitUpId exists in Firebase Sent Requests Collection
        snapshot = await _firestore
            .collection(Paths.usersPath)
            .doc(uid)
            .collection(Paths.sentRequestsPath)
            .where('username', isEqualTo: hitUpId)
            .limit(1)
            .get();

        if (snapshot.docs.length > 0) {
          return MozIdLocation.InSentRequests;
        } else {
          return MozIdLocation.Nowhere;
        }
      }
    }
  }

  @override
  Future<void> removeFromFriendRequestsCollection(String phoneNumber) async {
    // remove from my friend requests collection
    CollectionReference usersRef = _firestore.collection(Paths.usersPath);

    await usersRef
        .doc(uid)
        .collection(Paths.friendRequestsPath)
        .doc(phoneNumber)
        .delete();
  }

  @override
  void removeFromSentRequestsCollection(String phoneNumber) {
    // remove from the other user's sent requests collection
    CollectionReference usersRef = _firestore.collection(Paths.usersPath);

    usersRef
        .doc(phoneNumber)
        .collection(Paths.sentRequestsPath)
        .doc(uid)
        .delete();
  }
}
