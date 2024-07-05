// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:url_launcher/url_launcher.dart";

// Project imports:
import "package:qr_code_gen/main.dart";
import "package:qr_code_gen/pages/scan_history.dart";
import "package:qr_code_gen/utils/db.dart";

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

  ThemeMode theme = ThemeMode.system;
  bool autoOpenLinks = false;
  bool scanHistory = true;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
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

  void _rebuildAppContainer() {
    appContainerKey.currentState?.setState(() {});
  }

  void loadPreferences() {
    setState(() {
      theme = ThemeMode.values.byName(prefs.getString("theme") ?? "system");
      autoOpenLinks = prefs.getBool("autoOpenLinks") ?? false;
      scanHistory = prefs.getBool("scanHistory") ?? true;
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

  final MaterialStateProperty<Icon?> scanHistoryIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.history);
      }
      return const Icon(Icons.history_toggle_off);
    },
  );

  void _deleteAllScans() {
    DatabaseHelper.instance.deleteAllScans();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.settings,
        size: 26.0,
      ),
      onPressed: () {
        loadPreferences();

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
                                const Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                ),
                                Text(
                                  "Settings",
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              top: 16,
                              bottom: 32,
                            ),
                            child: Column(
                              children: [
                                Card(
                                  child: Builder(
                                    builder: (context) {
                                      return ListTile(
                                        leading: const Icon(Icons.dark_mode),
                                        title: const Text("Theme"),
                                        subtitle: Text(
                                          "Current theme : ${theme.name.capitalize}",
                                        ),
                                        onTap: () {
                                          final RenderBox listTileRenderBox =
                                              context.findRenderObject()!
                                                  as RenderBox;
                                          final RenderBox overlayRenderBox =
                                              Overlay.of(context)
                                                      .context
                                                      .findRenderObject()!
                                                  as RenderBox;
                                          final RelativeRect position =
                                              RelativeRect.fromRect(
                                            Rect.fromPoints(
                                              listTileRenderBox.localToGlobal(
                                                listTileRenderBox.size
                                                    .centerRight(Offset.zero),
                                                ancestor: overlayRenderBox,
                                              ),
                                              listTileRenderBox.localToGlobal(
                                                listTileRenderBox.size
                                                    .bottomRight(Offset.zero),
                                                ancestor: overlayRenderBox,
                                              ),
                                            ),
                                            Offset.zero & overlayRenderBox.size,
                                          );

                                          showMenu<ThemeMode>(
                                            context: context,
                                            position: position,
                                            items: <PopupMenuEntry<ThemeMode>>[
                                              const PopupMenuItem<ThemeMode>(
                                                value: ThemeMode.system,
                                                child: Text("System"),
                                              ),
                                              const PopupMenuItem<ThemeMode>(
                                                value: ThemeMode.light,
                                                child: Text("Light"),
                                              ),
                                              const PopupMenuItem<ThemeMode>(
                                                value: ThemeMode.dark,
                                                child: Text("Dark"),
                                              ),
                                            ],
                                          ).then((ThemeMode? value) {
                                            if (value != null) {
                                              prefs.setString(
                                                "theme",
                                                value.name,
                                              );
                                              setState(() {
                                                theme = value;
                                              });
                                              _rebuildAppContainer();
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.open_in_new),
                                    title:
                                        const Text("Automatically open links"),
                                    subtitle: const Text(
                                      "Automatically open links in the default browser",
                                    ),
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
                                    leading: const Icon(Icons.history),
                                    title: const Text("Scan history"),
                                    subtitle: const Text(
                                      "Keep track of previously scanned codes",
                                    ),
                                    trailing: Switch(
                                      value: scanHistory,
                                      thumbIcon: scanHistoryIcon,
                                      onChanged: (bool value) {
                                        prefs.setBool("scanHistory", value);

                                        setState(() {
                                          scanHistory = value;
                                        });

                                        if (!value) {
                                          _deleteAllScans();
                                        }

                                        (scanHistoryKey.currentState
                                                as ScanHistoryState?)
                                            ?.loadScans();
                                      },
                                    ),
                                  ),
                                ),
                                Card(
                                  child: ListTile(
                                    splashColor: Theme.of(context).splashColor,
                                    onTap: _launchUrl,
                                    leading:
                                        const Icon(Icons.folder_copy_outlined),
                                    title: const Text("Github"),
                                    subtitle: const Text(
                                      "Checkout the source code",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w100,
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading:
                                      const Icon(Icons.build_circle_outlined),
                                  title: const Text("Version"),
                                  subtitle: Text(
                                    "${_packageInfo.version} (build : ${_packageInfo.buildNumber})",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w100,
                                    ),
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
