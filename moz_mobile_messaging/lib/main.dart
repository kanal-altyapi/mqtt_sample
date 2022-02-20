import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_mobile_messaging/splashscreen.dart';
import 'package:moz_mobile_messaging/utils/SharedObjects.dart';
import 'package:provider/provider.dart';
import 'module/auth/state_provider/number_state.dart';
import 'module/chat/blocs/chat_bloc.dart';
import 'module/firebase/utils/firebase_utils.dart';
import 'module/home/blocs/home_bloc.dart';
import 'module/mqtt/state_provider/mqtt_state.dart';
import 'module/push/utils/firebase_messaging_utils.dart';
import 'module/timer/blocs/timer_bloc.dart';

void _onBackgroundMessage(dynamic remoteMessage) {
  print('main dart içerisindeyim!!!');
  print(remoteMessage);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebaseUtil.initialize();
  await firebaseMessagingUtils.initialize(_onBackgroundMessage, _onBackgroundMessage);
  SharedObjects.prefs = await CachedSharedPreferences.getInstance();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<ChatBloc>(
        create: (context) => ChatBloc(),
      ),
      BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(),
      ),
      BlocProvider<TimerBloc>(
        create: (context) => TimerBloc(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MQTTState>(create: (context) => MQTTState()),
        ChangeNotifierProvider<NumberState>(
          create: (context) => NumberState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '',
        theme: ThemeData(
          primaryColor: Colors.white,
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
