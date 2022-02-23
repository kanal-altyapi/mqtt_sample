import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:moz_mobile_messaging/module/auth/models/session_model.dart';
import 'package:moz_mobile_messaging/module/chat/screens/chat_home_screen.dart';

import '../../../config/Constants.dart';
import '../../../utils/SharedObjects.dart';
import '../../../widgets/name_text_field.dart';
import '../../home/screens/home_screen.dart';

class EnterName extends StatefulWidget {
  @override
  _EnterNameState createState() => _EnterNameState();
}

class _EnterNameState extends State<EnterName> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  //Firestore firestore = Firestore.instance;
  bool isLoading = false;

  Future<void> saveFullName(String firstname, String lastname) async {
    String? uid = SharedObjects.prefs.getString(Constants.sessionUid);

    String fullName = '$firstname $lastname';

    await SharedObjects.prefs.setString(Constants.sessionUsername, firstname);
    await SharedObjects.prefs.setString(Constants.fullName, fullName);

    //DocumentReference ref = firestore.collection(Paths.usersPath).document( uid); //reference of the user's document node in database/users. This node is created using uid
    var data = {'name': fullName};
    //await ref.setData(data, merge: true); // set the photourl, age and username
    await SharedObjects.prefs.setString(Constants.fullName, fullName);
    setFullname(fullName);
    setUsername(firstname);
  }

  Widget buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildEnterNameScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 40.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Center(
              child: Text("What's your name?",
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            const SizedBox(height: 8.0),
            Column(
              children: [
                NameTextField(
                  hintText: 'Adınız',
                  controller: firstNameController,
                ),
                NameTextField(
                  hintText: 'Soyadınız',
                  controller: lastNameController,
                ),
                const SizedBox(height: 10.0),
                // const Text("This name will appear when someone searches for you "
                //     "on HitUp")
              ],
            ),
            const SizedBox(height: 40.0),
            MaterialButton(
              padding: EdgeInsets.all(0),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  await saveFullName(firstNameController.text, lastNameController.text);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  isLoading = false;
                }
              },
              elevation: 10.0,
              color: Colors.blueAccent[400],
              child: const Text(
                'Sonraki',
                style: TextStyle(color: Colors.white, fontSize: 21.0, letterSpacing: 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? buildLoadingScreen() : buildEnterNameScreen(),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}
