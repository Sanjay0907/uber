import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:uber/common/controller/provider/authProvider.dart';
import 'package:uber/common/controller/provider/locattionProvider.dart';
import 'package:uber/common/controller/provider/profileDataProvider.dart';
import 'package:uber/common/view/signInLogic/signInLogin.dart';
import 'package:uber/constant/utils/colors.dart';
import 'package:uber/driver/controller/provider/rideRequestProvider.dart';
import 'package:uber/driver/controller/services/bottomNavBarRiderProvider.dart';
import 'package:uber/driver/controller/services/mapsProviderDriver.dart';
import 'package:uber/firebase_options.dart';
import 'package:uber/rider/controller/provider/bottomNavBarRiderProvider/bottomNavBarRiderProvider.dart';
import 'package:uber/rider/controller/provider/tripProvider/rideRequestProvider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Uber());
}

class Uber extends StatefulWidget {
  const Uber({super.key});

  @override
  State<Uber> createState() => _UberState();
}

class _UberState extends State<Uber> {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, _, __) {
      return MultiProvider(
        providers: [
          // ! Common Providers
          ChangeNotifierProvider<MobileAuthProvider>(
            create: (_) => MobileAuthProvider(),
          ),
          ChangeNotifierProvider<LocationProvider>(
            create: (_) => LocationProvider(),
          ),
          ChangeNotifierProvider<ProfileDataProvider>(
            create: (_) => ProfileDataProvider(),
          ),
          // ! Rider Providers
          ChangeNotifierProvider<BottomNavBarRiderProvider>(
            create: (_) => BottomNavBarRiderProvider(),
          ),
          ChangeNotifierProvider<RideRequestProvider>(
            create: (_) => RideRequestProvider(),
          ),
          // ! Driver Providers
          ChangeNotifierProvider<BottomNavBarDriverProvider>(
            create: (_) => BottomNavBarDriverProvider(),
          ),
          ChangeNotifierProvider<MapsProviderDriver>(
            create: (_) => MapsProviderDriver(),
          ),
          ChangeNotifierProvider<RideRequestProviderDriver>(
            create: (_) => RideRequestProviderDriver(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              color: white,
              elevation: 0,
            ),
          ),
          home: const SignInLogic(),
        ),
      );
      // return
    });
  }
}
