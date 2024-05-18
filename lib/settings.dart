// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:package_info_plus/package_info_plus.dart";
import "package:provider/provider.dart";
import "package:url_launcher/url_launcher.dart";

// Project imports:
import "package:qr_code_gen/main.dart";
import "package:qr_code_gen/utils/theme_preference.dart";

class Settings extends StatefulWidget {
  const Settings({
    super.key,
  });

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  PackageInfo _packageInfo = PackageInfo(
    appName: "Unknown",
    packageName: "Unknown",
    version: "Unknown",
    buildNumber: "Unknown",
    buildSignature: "Unknown",
    installerStore: "Unknown",
  );

  bool isDarkTheme = false;
  bool openCamOnStart = false;
  bool autoOpenLinks = false;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    checkIfDarkTheme();

    openCamOnStart = prefs.getBool("openCamOnStart") ?? false;
    autoOpenLinks = prefs.getBool("autoOpenLinks") ?? false;
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  final Uri _url = Uri.parse("https://github.com/sankethsj/qr-code-generator");

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $_url");
    }
  }

  Future<void> checkIfDarkTheme() async {
    final bool isDark = prefs.getBool("isDark") ?? false;
    setState(() {
      isDarkTheme = isDark;
    });
  }

  final WidgetStateProperty<Icon?> themeIcon = WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
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
          showDragHandle: true,
          context: context,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
              expand: false,
              maxChildSize: 0.7,
              minChildSize: 0.4,
              builder: (context, scrollController) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return SafeArea(
                      top: false,
                      maintainBottomViewPadding: true,
                      child: ListView(
                        controller: scrollController,
                        children: <Widget>[
                          Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.settings,
                                  size: 32,
                                ),
                                const Padding(padding: EdgeInsets.only(top: 8, bottom: 8)),
                                Text(
                                  "Settings",
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const Padding(padding: EdgeInsets.only(bottom: 8)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 32),
                            child: Column(
                              children: [
                                Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.dark_mode),
                                    title: Text('Switch to ${isDarkTheme ? 'Light' : 'Dark'} mode'),
                                    subtitle: Text('Current theme : ${isDarkTheme ? 'DARK' : 'LIGHT'}'),
                                    trailing: Switch(
                                      thumbIcon: themeIcon,
                                      value: isDarkTheme,
                                      onChanged: (bool value) {
                                        final themePreference = Provider.of<ThemePreference>(context, listen: false);
                                        themePreference.toggleTheme();

                                        setState(() {
                                          isDarkTheme = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.camera_alt_outlined),
                                    title: const Text("Open camera on start"),
                                    subtitle: const Text("Open camera on app start to scan QR codes"),
                                    trailing: Switch(
                                      value: openCamOnStart,
                                      onChanged: (bool value) {
                                        prefs.setBool("openCamOnStart", value);

                                        setState(() {
                                          openCamOnStart = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.open_in_new),
                                    title: const Text("Automatically open links"),
                                    subtitle: const Text("Automatically open links in the default browser"),
                                    trailing: Switch(
                                      value: autoOpenLinks,
                                      onChanged: (bool value) {
                                        prefs.setBool("autoOpenLinks", value);

                                        setState(() {
                                          autoOpenLinks = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Card(
                                  child: ListTile(
                                    splashColor: Theme.of(context).splashColor,
                                    onTap: _launchUrl,
                                    leading: const Icon(Icons.folder_copy_outlined),
                                    title: const Text("Github"),
                                    subtitle: const Text(
                                      "Checkout the source code",
                                      style: TextStyle(fontWeight: FontWeight.w100),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.build_circle_outlined),
                                  title: const Text("Version"),
                                  subtitle: Text(
                                    "${_packageInfo.version} (build : ${_packageInfo.buildNumber})",
                                    style: const TextStyle(fontWeight: FontWeight.w100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
