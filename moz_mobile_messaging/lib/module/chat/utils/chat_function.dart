import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:moz_mobile_messaging/config/constants.dart';
import 'package:moz_mobile_messaging/core/abstract/base_functions.dart';
import 'package:moz_mobile_messaging/module/chat/models/models/chat_message.dart';
import 'package:moz_mobile_messaging/module/local_db/utils/db_manager.dart';
import 'package:moz_mobile_messaging/module/mqtt/state_provider/mqtt_state.dart';
import 'package:moz_mobile_messaging/module/mqtt/utils/mqtt_manager.dart';
import 'package:moz_mobile_messaging/utils/SharedObjects.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import '../../../config/Paths.dart';


class ChatFunction extends BaseChatFunction {
  MQTTManager? _manager;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? myUid = SharedObjects.prefs.getString(Constants.sessionUid);
  @override
  void blockUser(BuildContext context, String chatId) {
    // TODO: implement blockUser
  }

  @override
  Future<String> createChatIdForContact(String contactPhoneNumber) async {
    String chatId;
    String? uId = SharedObjects.prefs.getString(Constants.sessionUid);
    CollectionReference usersCollection =
        _firestore.collection(Paths.usersPath);
    DocumentReference userRef = usersCollection.doc(uId);
    DocumentReference contactRef = usersCollection.doc(contactPhoneNumber);
    DocumentSnapshot userSnapshot = await userRef.get();

    // if chatId doesn't exists for that contact then create new ChatId and update it
    // for both the user and the contact
    // else use the chatId which already exists
    if (userSnapshot.get('chats') == null ||
        userSnapshot.get('chats')[contactPhoneNumber] == null) {
      chatId = createChatId();
      await userRef.set({
        'chats': {contactPhoneNumber: chatId}
      }, SetOptions( merge: true));
      await contactRef.set({
        'chats': {uId: chatId}
      }, SetOptions( merge: true));
    } else {
      chatId = userSnapshot.get('chats')[contactPhoneNumber];
    }

    return chatId;
  }

  String createChatId() {
    final Random _random = Random.secure();
    final int idLength = 16; // length of the chatId

    var values = List<int>.generate(idLength, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<List<ChatMessage>> getAllMsgsFromMessagesTable(String chatId) async {
    // OOZ burada mesajlar Local DB 'den okunur.
    List<ChatMessage> messagesFromDb = await DBManager.db.readAllMessagesfromMessagesTable(chatId);
    return Future.value(messagesFromDb);
  }

  Future<File?> testCompressAndGetFile(File file) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tempPath + "/temp.jpg",
      minHeight: 400,
      minWidth: 400,
      quality: 80,
    );
    return result;
  }

  @override
  void sendImageToServer(BuildContext context, File imageFile, String chatId)async {
     _manager ??= context.read<MQTTState>().manager;

    // compress the image & make it smaller in size
    File? newFile = await testCompressAndGetFile(imageFile);

    // change the image to bytes format
    String base64Image = base64Encode(newFile!.readAsBytesSync());
    String msgToSend =
        '{"msg" : "$base64Image", "type" : "image", "uid" : "$myUid"}';

    while (!_manager!.isConnectionActive()) {
      print("NOT CONNECTED BEFORE PUBLISHING");
      await Future.delayed(Duration(seconds: 1));
    }

    print("CONNECTED BEFORE PUBLISHING");
    _manager!.publishMessage(msgToSend, chatId);
  }

  @override
  void sendMessageToServer(BuildContext context, String msg, String chatId) {
    _manager ??= context.read<MQTTState>().manager;
    debugPrint("calling send message to server");
    Map msgMap = {"msg": "$msg", "type": "text", "uid": "$myUid"};
    String msgToSend = json.encode(msgMap);
    _manager!.publishMessage(msgToSend, chatId);
  }

  @override
  void sendServiceMsgToServer(BuildContext context, String msg, String chatId) {
  _manager ??= context.read<MQTTState>().manager;
    DBManager.db.updateBlockStatus(0, chatId);
    _manager!.unSubscribeTopic(chatId);
  }

  @override
  void unBlockUser(BuildContext context, String chatId) {
 _manager ??= context.read<MQTTState>().manager;
    DBManager.db.updateBlockStatus(1, chatId);
    _manager!.subscribeTopic(chatId);
  }
}
