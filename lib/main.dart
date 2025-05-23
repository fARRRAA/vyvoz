import 'package:flutter/material.dart';
import 'package:vyvoz/pages/home_page.dart';
import 'package:vyvoz/pages/login_page.dart';
import 'package:vyvoz/pages/main_page.dart';
import 'package:vyvoz/pages/startup_page.dart';
import 'package:vyvoz/pages/route/route_page.dart';
import 'package:vyvoz/pages/route/treatment_plants_selector_page.dart';
import 'package:vyvoz/pages/route/route_payment_page.dart';
import 'package:vyvoz/pages/route/route_finish_page.dart';

void main()  {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TriEco',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xff2B2D42)
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xff2B2D42)),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide.none)))),
        useMaterial3: true,
      ),
      
      initialRoute: '/',
      routes: {
        '/' : (context) => StartupPage(),
        '/login':(context) => LoginPage(),
        '/home':(context)=>MainPage(),
        // Маршруты для завершения рейса
        '/route': (context) => RoutePage(),
        '/treatment_plants_selector': (context) => TreatmentPlantsSelectorPage(),
        '/route_payment': (context) => RoutePaymentPage(),
        '/route_finish': (context) => RouteFinishPage(),
      },
    );
  }
}
