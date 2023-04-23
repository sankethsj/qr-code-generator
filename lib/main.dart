import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_gen/pages/qr_generator.dart';
import 'package:qr_code_gen/pages/qr_scanner.dart';

void main() {
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  static final _defaultLightColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
    accentColor: Colors.blueAccent,
    errorColor: Colors.red,
    backgroundColor: const Color.fromARGB(255, 189, 222, 248),
    primaryColorDark: const Color.fromARGB(255, 6, 68, 119),
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
    accentColor: Colors.blueAccent,
    errorColor: Colors.red,
    brightness: Brightness.dark,
  );

  int selectedPageIndex = 0;

  List pages = [
    const QrGenerator(),
    const QrScanner(),
  ];

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
          fontFamily: 'Raleway',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          fontFamily: 'Raleway',
        ),
        themeMode: ThemeMode.light,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'MyQR',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.settings,
                      size: 26.0,
                    ),
                  )),
            ],
          ),
          body: pages[selectedPageIndex],
          bottomNavigationBar: NavigationBar(
            backgroundColor: const Color.fromARGB(255, 221, 234, 255),
            selectedIndex: selectedPageIndex,
            onDestinationSelected: (int index) {
              setState(() {
                selectedPageIndex = index;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                selectedIcon: Icon(Icons.qr_code_2),
                icon: Icon(Icons.qr_code_2_outlined),
                label: 'QR Generator',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.qr_code_scanner),
                icon: Icon(Icons.qr_code_scanner_outlined),
                label: 'QR Scanner',
              ),
            ],
            animationDuration: const Duration(seconds: 1),
          ),
        ),
      );
    });
  }
}
