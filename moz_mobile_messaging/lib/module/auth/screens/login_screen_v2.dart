import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
// import 'package:coocoo/screens/otp_screen.dart';
// import 'package:coocoo/config/Constants.dart';
// import 'package:coocoo/functions/UserDataFunction.dart';
// import 'package:coocoo/stateProviders/number_state.dart';
// import 'package:coocoo/utils/SharedObjects.dart';
// import 'package:country_pickers/country.dart';
// import 'package:country_pickers/country_pickers.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../config/Constants.dart';
import '../../../utils/SharedObjects.dart';
import '../state_provider/number_state.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  // Firestore _firestore = Firestore.instance;
  TextEditingController mobileNumberController = TextEditingController();
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //UserDataFunction userDataFunction = UserDataFunction();

  String countryCode = '90';

  // TODO: Handle the exception nicely here instead of just printing out the error
  // final PhoneVerificationFailed _verificationFailed =
  //     (AuthException authException) {
  //   print(authException.message);
  // };

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
                  context.read<NumberState>().setPhoneNumber(
                      "$countryCode${mobileNumberController.text}");
                  await SharedObjects.prefs.setString(Constants.sessionCountryCode, countryCode);
                  // await userDataFunction.verifyPhoneNumber(
                  //     context,
                  //     '+$countryCode' + mobileNumberController.text.toString(),
                  //     _verificationFailed);
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => OTPScreen()));
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
}
