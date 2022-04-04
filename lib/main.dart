import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kayseri_ulasim/controller/language_controller.dart';
import 'package:kayseri_ulasim/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageController()),
      ],
      child: EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('tr', 'TR')],
        path:
            'assets/translations', 
        fallbackLocale: Locale('en', 'US'),
        child: MyApp(),
      ),
    ),
  );
  //await AndroidAlarmManager.initialize(); //initialize alarm_managera
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Kayseri Ulaşım',
      home: MyHomePage(),
    );
  }
}
