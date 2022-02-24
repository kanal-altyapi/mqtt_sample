import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../models/my_contact.dart';
import '../../../user_data/utils/UserDataFunction.dart';
 

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc() : super(InitialContactsState());

  UserDataFunction userDataFunction = UserDataFunction();

  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
    if (event is FetchContactsEvent) {
      try {
        yield FetchingContactsState();
        List<MyContact> contacts = await userDataFunction.getContactsFromDB();
        add(ReceivedContactsEvent(contacts));
      } on Exception catch (e) {
        print(e);
      }
    }
    if (event is ReceivedContactsEvent) {
      yield FetchedContactsState(event.contacts);
    }
  }
}
