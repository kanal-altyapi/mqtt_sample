import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/abstract/base_functions.dart';
import '../../auth/state_provider/number_state.dart';
import '../../chat/utils/chat_function.dart';
import '../../push/utils/firebase_messaging_utils.dart';

class UserDataFunction extends BaseUserDataFunction {
  //Firestore _firestore = Firestore.instance;
  ChatFunction chatFunction = ChatFunction();

  @override
  void dispose() {}

  @override
  Future<void> loadPhoneContactsV2(BuildContext context) {
    // TODO: implement loadPhoneContactsV2
    throw UnimplementedError();
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
      return permissionStatus[Permission.contacts] ?? PermissionStatus.restricted;
    } else {
      return permission;
    }
  }
}
