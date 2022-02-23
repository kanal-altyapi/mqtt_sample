import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../config/Paths.dart';
import '../../../config/constants.dart';
import '../../../core/abstract/base_functions.dart';
import '../../../utils/SharedObjects.dart';
import '../../auth/state_provider/number_state.dart';
import '../../chat/utils/chat_function.dart';
import '../../local_db/utils/db_manager.dart';
import '../../mqtt/state_provider/mqtt_state.dart';
import '../../mqtt/utils/mqtt_manager.dart';
import '../../push/utils/firebase_messaging_utils.dart';

class UserDataFunction extends BaseUserDataFunction {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ChatFunction chatFunction = ChatFunction();

  @override
  void dispose() {}

  void removeUninstalledUserFromDB(BuildContext context, String tempNum) async {
    final contactRef = _firestore.collection(Paths.usersPath).doc(tempNum);

    contactRef.get().then((docSnapshot) async {
      if (!docSnapshot.exists) {
        // delete the contact from local Database
        await DBManager.db.deleteContact(tempNum);
      }
    });
  }

  dynamic cleanNumber(Contact dirtyNumber, String countryCode) {
    // when we clean a number, we first remove all the white spaces and hyphens and then
    // if the number does not has a country code,i.e, if its length is less than 11
    // then we add the user's country code.
    try {
      String num = dirtyNumber.phones!.first.value!;
      String num2 = num.replaceAll(RegExp(r"\D+"), '');
      if (num2.length < 11) {
        return "$countryCode$num2";
      } else {
        return num2;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> addInstalledUserToDBANDSubscribe(BuildContext context, String tempNum, String contactName) async {
    final contactRef = _firestore.collection(Paths.usersPath).doc(tempNum);

    contactRef.get().then((docSnapshot) async {
      // if the user has installed the app then add him as a contact to my db
      // else do nothing
      if (docSnapshot.exists) {
        print("USER $tempNum EXISTS IN DB");
        String chatId = await chatFunction.createChatIdForContact(tempNum);

        // create a row for this user, i.e add the contact to my local db
        //String photoUrl = docSnapshot.data["photoUrl"];
        String username = docSnapshot.get('username');
        await DBManager.db.createRow(docSnapshot.id, chatId, contactName, username, '', 1); // true because here this is a phone contact

        // Subscribe to the chatId
        MQTTManager? manager = context.read<MQTTState>().manager;
        print("SUBSCRIBING TO TOPIC : $chatId");
        manager!.subscribeTopic(chatId);
      }
    }).catchError((e) {
      print("e");
    });
  }

  @override
  Future<void> loadPhoneContactsV2(BuildContext context) async {
    Iterable<Contact> _contacts = await ContactsService.getContacts(withThumbnails: false);
    String? countryCode = SharedObjects.prefs.getString(Constants.sessionCountryCode);

    try {
      await Future.forEach(_contacts, (Contact _contact) async {
        String tempNum = cleanNumber(_contact, countryCode!);
        String contactName = _contact.displayName!;

        if (tempNum != null) {
          bool contactExists = await DBManager.db.checkIfContactExistsInDb(tempNum);

          if (!contactExists) {
            await addInstalledUserToDBANDSubscribe(context, tempNum, contactName);
          } else if (contactExists) {
            // however if contact exists in local db but does not exist in primary firestore
            // users database because he deleted his account then remove him from local db
            removeUninstalledUserFromDB(context, tempNum);
          }
        }
      });
    } catch (e, s) {
      print(s);
    }
  }

  @override
  void onShare(BuildContext context) {
    // TODO: implement onShare
  }

  @override
  Future<void> sendNotification({
    String toUid = '',
    String title = '',
    String content = '',
  }) async {
    // TODO: implement sendNotification

    await firebaseMessagingUtils.sendPushMessage();
  }

  @override
  Future<void> verifyPhoneNumber(BuildContext context, String phoneNum, Function verificationFailed) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String? autoRetrievedSmsCodeForTesting = '123456';
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNum,
        timeout: Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential authCredential) {
          debugPrint('verificationCompleted run');
        },
        verificationFailed: (FirebaseAuthException authException) async {
          debugPrint('verificationFailed run');
          await verificationFailed(authException);
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          debugPrint('codeSent run');
          context.read<NumberState>().setOTP(verificationId);
        },
        codeAutoRetrievalTimeout: (String value) {},
        autoRetrievedSmsCodeForTesting: autoRetrievedSmsCodeForTesting);
  }

  @override
  Future<PermissionStatus> askContactPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    return permissionStatus;
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted && permission != PermissionStatus.restricted) {
      Map<Permission, PermissionStatus> permissionStatus = await [
        Permission.contacts,
      ].request();
      //return permissionStatus[Permission.contacts] ?? PermissionStatus.restricted;
      return PermissionStatus.granted;
    } else {
      return permission;
    }
  }
}
