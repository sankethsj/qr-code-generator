import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_gen/pages/qr_generator.dart';
import 'package:qr_code_gen/pages/qr_scanner.dart';
import 'package:qr_code_gen/settings.dart';
import 'package:qr_code_gen/utils/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('isDark') ?? false;

  runApp(Main(isDark: isDark));
}

class Main extends StatefulWidget {
  final bool isDark;
  const Main({super.key, required this.isDark});

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  int selectedPageIndex = 0;

  List pages = [
    const QrScanner(),
    const QrGenerator(),
  ];

  @override
  Widget build(BuildContext context) {
    const FlexScheme usedScheme = FlexScheme.redM3;

    return ChangeNotifierProvider(
        create: (context) => ThemePreference(widget.isDark),
        builder: (context, snapshot) {
          final themePreference = Provider.of<ThemePreference>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: FlexThemeData.light(
              scheme: usedScheme,
              appBarElevation: 0.5,
              useMaterial3: true,
              fontFamily: 'Raleway',
            ),
            darkTheme: FlexThemeData.dark(
              scheme: usedScheme,
              appBarElevation: 2,
              useMaterial3: true,
              fontFamily: 'Raleway',
            ),
            themeMode: themePreference.currentTheme,
            home: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'MyQR',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                actions: const <Widget>[Settings()],
              ),
              body: pages[selectedPageIndex],
              bottomNavigationBar: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                  ),
                ),
                child: NavigationBar(
                  elevation: 1,
                  selectedIndex: selectedPageIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      selectedPageIndex = index;
                    });
                  },
                  destinations: const <NavigationDestination>[
                    NavigationDestination(
                      selectedIcon: Icon(Icons.qr_code_scanner),
                      icon: Icon(Icons.qr_code_scanner_outlined),
                      label: 'QR Scanner',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.qr_code_2),
                      icon: Icon(Icons.qr_code_2_outlined),
                      label: 'QR Generator',
                    ),
                  ],
                  animationDuration: const Duration(seconds: 1),
                ),
              ),
            ),
          );
        });
  }
}
