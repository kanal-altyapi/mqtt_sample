import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_mobile_messaging/splashscreen.dart';
import 'package:moz_mobile_messaging/utils/SharedObjects.dart';
import 'package:provider/provider.dart';
import 'module/chat/blocs/chat_bloc.dart';
import 'module/firebase/utils/firebase_utils.dart';
import 'module/home/blocs/home_bloc.dart';
import 'module/mqtt/state_provider/mqtt_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseUtils.initialize();
  SharedObjects.prefs = await CachedSharedPreferences.getInstance();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<ChatBloc>(
        create: (context) => ChatBloc(),
      ),
      BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(),
      ),
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
