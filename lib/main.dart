// Flutter imports:
import "dart:io";

import "package:device_info_plus/device_info_plus.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_displaymode/flutter_displaymode.dart";

// Package imports:
import "package:provider/provider.dart";
import "package:qr_code_gen/utils/app_theme.dart";
import "package:shared_preferences/shared_preferences.dart";

// Project imports:
import "package:qr_code_gen/pages/qr_generator.dart";
import "package:qr_code_gen/pages/qr_scanner.dart";
import "package:qr_code_gen/settings.dart";
import "package:qr_code_gen/utils/theme_preference.dart";

final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
late final SharedPreferences prefs;
bool isLaunch = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool("isDark") ?? false;

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
    setOptimalDisplayMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setSystemStyle(Theme.of(context));
    });

    return ChangeNotifierProvider(
      create: (context) => ThemePreference(widget.isDark),
      builder: (context, snapshot) {
        final themePreference = Provider.of<ThemePreference>(context);
        return DynamicColorBuilder(
          builder: (ColorScheme? light, ColorScheme? dark) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getTheme(Brightness.light, light, dark),
              darkTheme: AppTheme.getTheme(Brightness.dark, light, dark),
              themeMode: themePreference.currentTheme,
              home: Scaffold(
                appBar: AppBar(
                  title: const Text(
                    "OmniQR",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  actions: const <Widget>[Settings()],
                ),
                body: pages[selectedPageIndex] as Widget,
                bottomNavigationBar: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                    ),
                  ),
                  child: NavigationBar(
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
                        label: "QR Scanner",
                      ),
                      NavigationDestination(
                        selectedIcon: Icon(Icons.qr_code_2),
                        icon: Icon(Icons.qr_code_2_outlined),
                        label: "QR Generator",
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Future<void> setOptimalDisplayMode() async {
  if (!Platform.isAndroid) return;
  final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
  if (androidInfo.version.sdkInt < 23) return;

  await FlutterDisplayMode.setHighRefreshRate();
}

Future<void> setSystemStyle(ThemeData theme) async {
  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    final bool edgeToEdge = androidInfo.version.sdkInt >= 29;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: edgeToEdge ? Colors.transparent : theme.colorScheme.surface,
        systemNavigationBarDividerColor: edgeToEdge ? Colors.transparent : theme.colorScheme.surface,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.light ? Brightness.dark : Brightness.light,
      ),
    );
  } else {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }
}
