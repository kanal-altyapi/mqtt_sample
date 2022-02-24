import 'package:flutter/material.dart';

import '../../../models/my_contact.dart';
import '../../chat/screens/chat_screen.dart';
import 'contact_card.dart';

// ignore: must_be_immutable
class ContactRowWidget extends StatelessWidget {
  ContactRowWidget({
    required this.contact,
  });
  final MyContact contact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(contact),
              ));
        },
        child: ContactCard(
          name: contact.name!,
          profilePic: contact.photoUrl,
          status: '@${contact.username ?? contact.phoneNumber}',
        ));
  }
}
