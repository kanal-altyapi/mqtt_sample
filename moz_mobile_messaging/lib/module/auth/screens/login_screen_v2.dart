import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moz_mobile_messaging/module/auth/screens/otp_screen.dart';
import 'package:provider/provider.dart';
import '../../../config/Constants.dart';
import '../../../utils/SharedObjects.dart';
import '../../user_data/utils/UserDataFunction.dart';
import '../models/session_model.dart';
import '../state_provider/number_state.dart';
import 'enter_name.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  // Firestore _firestore = Firestore.instance;
  TextEditingController mobileNumberController = TextEditingController();
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  UserDataFunction userDataFunction = UserDataFunction();
  String phoneNumber = '';
  String countryCode = '90';

  Future<void> _verificationFailed   (FirebaseAuthException authException) async{
    debugPrint(authException.message);
  }

  Future<bool> _showContinueDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Telefon kodunuzu doğrulayacağız: +$countryCode ${mobileNumberController.text}'),
            content: Text('Emin misiniz, değiştirmek ister misiniz'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Güncelle'),
              ),
              FlatButton(
                onPressed: () async {
                  context.read<NumberState>().setPhoneNumber("$countryCode${mobileNumberController.text}");
                  await SharedObjects.prefs.setString(Constants.sessionCountryCode, countryCode);
                  await userDataFunction.verifyPhoneNumber(context, '+$countryCode' + mobileNumberController.text.toString(), _verificationFailed);
                  await _login();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OTPScreen()));
                },
                child: Text('Tamam'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            const SizedBox(
              width: 8.0,
            ),
            Text("+${country.phoneCode} ${country.isoCode}"),
          ],
        ),
      );

  @override
  void dispose() {
    mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<NumberState>(
        create: (context) => NumberState(),
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Container(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 22.0),
                child: ListView(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              'Telefon numaranızı doğrulayınız.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Constants.textStuffColor,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            const Text(
                              'SMS doğrulaması için lütfen telefon numaranızı giriniz.',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            CountryPickerDropdown(
                              initialValue: 'Tr',

                              itemBuilder: _buildDropdownItem,
//                                itemFilter:  ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
                              sortComparator: (Country a, Country b) => a.isoCode.compareTo(b.isoCode),
                              onValuePicked: (Country country) {
                                setState(() {
                                  countryCode = country.phoneCode;
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50.0),
                              child: TextFormField(
                                controller: mobileNumberController,
                                maxLengthEnforced: true,
                                maxLength: 10,
                                cursorColor: Constants.stuffColor,
                                style: const TextStyle(fontSize: 20.0),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Telefon numarası',
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(r'\s+')) // no spaces allowed
                                ],
                                onChanged: (value) {
                                  phoneNumber = value;
                                },
                                validator: (value) {
                                  if (value!.length != 10) {
                                    return 'Please enter 10 digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        RaisedButton(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                          color: Constants.stuffColor,
                          child: const Text(
                            'Sonraki',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              letterSpacing: 1.0,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _showContinueDialog();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _login() async {
    await SharedObjects.prefs.setBool('login', false);
    await SharedObjects.prefs.setString(Constants.sessionUid, countryCode + phoneNumber);
    //await SharedObjects.prefs.setString(Constants.sessionUsername, ');
    //await SharedObjects.prefs.setString(Constants.fullName, username);
    initialSession(username: '', phoneNumber: phoneNumber, fullName: '');

    return true;
  }
}
