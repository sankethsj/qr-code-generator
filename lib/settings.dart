import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_gen/utils/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  bool isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    checkIfDarkTheme();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  final Uri _url = Uri.parse('https://github.com/sankethsj/qr-code-generator');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  checkIfDarkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDark') ?? false;
    setState(() {
      isDarkTheme = isDark;
    });
  }

  final MaterialStateProperty<Icon?> themeIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.dark_mode);
      }
      return const Icon(Icons.light_mode);
    },
  );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.settings,
        size: 26.0,
      ),
      onPressed: () {
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              size: 24.0,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          )),
                      child: ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text(
                            'Switch to ${isDarkTheme ? 'Light' : 'Dark'} mode'),
                        subtitle: Text(
                            'Current theme : ${isDarkTheme ? 'DARK' : 'LIGHT'}'),
                        trailing: Switch(
                          thumbIcon: themeIcon,
                          value: isDarkTheme,
                          onChanged: (bool value) {
                            final themePreference =
                                Provider.of<ThemePreference>(context,
                                    listen: false);
                            themePreference.toggleTheme();

                            setState(() => isDarkTheme = !isDarkTheme);
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          )),
                      child: ListTile(
                        splashColor: Theme.of(context).splashColor,
                        onTap: _launchUrl,
                        leading: const Icon(Icons.folder_copy_outlined),
                        title: const Text('Github'),
                        subtitle: const Text(
                          'Checkout the source code',
                          style: TextStyle(fontWeight: FontWeight.w100),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          )),
                      child: ListTile(
                        leading: const Icon(Icons.build_circle_outlined),
                        title: const Text('Version'),
                        subtitle: Text(
                          '${_packageInfo.version} (build : ${_packageInfo.buildNumber})',
                          style: const TextStyle(fontWeight: FontWeight.w100),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }
}
