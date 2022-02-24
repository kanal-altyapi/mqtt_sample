import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../../../config/Constants.dart';
import '../../../config/Paths.dart';
import '../../../config/design_constants.dart';
import '../../../core/abstract/base_functions.dart';
import '../../../models/my_contact.dart';
import '../../../utils/SharedObjects.dart';
import '../blocks/add_friends/add_friends_bloc.dart';
import '../widgets/add_friend_card.dart';
import '../widgets/friends_request_cart.dart';
import '../widgets/no_request_card.dart';
import '../widgets/send_request_card.dart';

enum RequestsType { FriendRequests, SentRequests }

class AddFriendsScreen extends StatefulWidget {
  @override
  _AddFriendsScreenState createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final TextEditingController hitupIdController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? uid = SharedObjects.prefs.getString(Constants.sessionUid);
  late AddFriendsBloc addFriendsBloc;
  final _formKey = GlobalKey<FormState>();

  Widget _buildRequestsStreamBuilder(
      double algo, RequestsType requestsType, BuildContext contex) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(Paths.usersPath)
          .doc(uid)
          .collection(requestsType == RequestsType.SentRequests
              ? Paths.sentRequestsPath
              : Paths.friendRequestsPath)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget toShow;
        if (snapshot.hasError) {
          toShow = MozIdTextWidget(
              algo: algo, text: 'Sorry! Not able to retrieve Data');
        } else {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              toShow = MozIdTextWidget(
                  algo: algo, text: 'Sorry! Not able to retrieve Data');
              break;
            case ConnectionState.waiting:
              toShow = Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 60,
                    width: 60,
                  ),
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.data!.docs.isEmpty) {
                toShow = NoRequestsCard(
                    algo: algo,
                    text: requestsType == RequestsType.SentRequests
                        ? 'You h'
                            'ave not sent any Friend Requests'
                        : 'You have No '
                            'Friend Requests');
              } else {
                toShow = Column(
                  children: snapshot.data!.docs
                      .map((e) => requestsType == RequestsType.SentRequests
                          ? SentRequestCard(MyContact.fromFireStore(e))
                          : FriendRequestCard(MyContact.fromFireStore(e),
                              addFriendsBloc, contex))
                      .toList(),
                );
              }
              break;
          }
        }
        return toShow;
      },
    );
  }

  @override
  void initState() {
    addFriendsBloc = BlocProvider.of<AddFriendsBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double algo = width / perfectWidth;
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(top: 12.0, right: 10.0, left: 10.0),
        child: ListView(
          children: [
            Row(
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 5.0),
                Expanded(
                    child: TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                        RegExp(r'\s+')) // no spaces allowed
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter a valid username";
                    }
                    return null;
                  },
                  controller: hitupIdController,
                  style: TextStyle(
                    fontSize: algo * 18.0,
                  ),
                  autocorrect: false,
                  cursorColor: Colors.blueGrey,
                  decoration: kHitUpIdTextFieldDecoration,
                )),
                SizedBox(width: algo * 10.0),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      addFriendsBloc
                          .add(SearchHitUpIdEvent(hitupIdController.text));
                    }
                    hitupIdController.clear();
                  },
                  child: Text(
                    'Search',
                    style: TextStyle(
                      letterSpacing: 0.5,
                      fontSize: algo * 21.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: BlocBuilder<AddFriendsBloc, AddFriendsState>(
                builder: (context, state) {
                  if (state is SearchingHitUpIdState) {
                    return SearchingCard(algo: algo);
                  }
                  if (state is HitUpIdAlreadyThere) {
                    if (state.hitUpIdLocation == MozIdLocation.InLocalDb) {
                      return MozIdTextWidget(
                          algo: algo,
                          text:
                              '@${state.hitUpId} already exists in your contacts!');
                    } else if (state.hitUpIdLocation ==
                        MozIdLocation.InFriendRequests) {
                      return MozIdTextWidget(
                          algo: algo,
                          text:
                              'You have already received a friend request from @${state.hitUpId}. Please'
                              ' check your Friend Requests List');
                    } else if (state.hitUpIdLocation ==
                        MozIdLocation.InSentRequests) {
                      return MozIdTextWidget(
                          algo: algo,
                          text:
                              'You have already sent a friend request to @${state.hitUpId}');
                    }
                  }
                  if (state is SendingFriendRequestState) {
                    return SearchingCard(algo: algo);
                  }
                  if (state is FriendRequestSentState) {
                    return SentRequestCard(state.friend);
                  }
                  if (state is HitUpIdExistsState) {
                    // return Text(state.friend.name);
                    return AddFriendCard(state.friend, () async {
                      // print(state.friend.phoneNumber);
                      addFriendsBloc
                          .add(AddButtonClickEvent(context, state.friend));
                    });
                  }
                  if (state is HitUpIdNotExistsState) {
                    return MozIdTextWidget(
                      algo: algo,
                      text: 'HitUp Id @${state.hitupId} not found!',
                    );
                  }
                  return SizedBox(height: 10.0);
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Friend Requests',
                  style: kRequestTitleStyle,
                ),
                SizedBox(height: 6.0),
                BlocBuilder<AddFriendsBloc, AddFriendsState>(
                  builder: (context, state) {
                    if (state is AcceptingFriendRequestState ||
                        state is DecliningFriendRequestState) {
                      return SearchingCard(algo: algo);
                    }
                    return _buildRequestsStreamBuilder(
                        algo, RequestsType.FriendRequests, context);
                  },
                ),
              ],
            ),
            SizedBox(height: 30.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Sent Requests',
                  style: kRequestTitleStyle,
                ),
                SizedBox(height: 6.0),
                _buildRequestsStreamBuilder(
                  algo,
                  RequestsType.SentRequests,
                  context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    hitupIdController.dispose();
    // addFriendsBloc.close();
  }
}

class SearchingCard extends StatelessWidget {
  const SearchingCard({
    Key? key,
    required this.algo,
  }) : super(key: key);

  final double algo;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.0),
        height: algo * 50.0,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class MozIdTextWidget extends StatelessWidget {
  final double algo;
  final String text;

  MozIdTextWidget({
    required this.algo,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: algo * 20.0,
                color: Constants.textStuffColor,
              )),
        ),
      ),
    );
  }
}
