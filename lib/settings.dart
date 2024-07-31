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
import "package:qr_code_gen/utils/utils.dart";

class SettingsButton extends StatefulWidget {
  const SettingsButton({
    super.key,
  });

  @override
  SettingsButtonState createState() => SettingsButtonState();
}

class SettingsButtonState extends State<SettingsButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.settings,
      ),
      onPressed: () {
        showBottomSheet(
          context: context,
          child: const SettingsBottomSheet(),
        );
      },
    );
  }
}

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({
    super.key,
  });

  @override
  SettingsBottomSheetState createState() => SettingsBottomSheetState();
}

class SettingsBottomSheetState extends State<SettingsBottomSheet> {
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
    loadPreferences();
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

  final WidgetStateProperty<Icon?> scanHistoryIcon = WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
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
    return BottomSheet(
      icon: Icons.settings,
      title: "Settings",
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
                    final RenderBox listTileRenderBox = context.findRenderObject()! as RenderBox;
                    final RenderBox overlayRenderBox = Overlay.of(context).context.findRenderObject()! as RenderBox;
                    final RelativeRect position = RelativeRect.fromRect(
                      Rect.fromPoints(
                        listTileRenderBox.localToGlobal(
                          listTileRenderBox.size.centerRight(Offset.zero),
                          ancestor: overlayRenderBox,
                        ),
                        listTileRenderBox.localToGlobal(
                          listTileRenderBox.size.bottomRight(Offset.zero),
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
              title: const Text("Automatically open links"),
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

                  (scanHistoryKey.currentState as ScanHistoryState?)?.loadScans();
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
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.build_circle_outlined),
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
    );
  }
}

class BottomSheet extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const BottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  double maxSize = 1;
  double get initSize => maxSize * (1 - .0001);

  void _setMaxChildSize(Size size) {
    setState(() {
      const double indicatorPadding = 48;
      const double errorPadding = 0;

      // get height of the container.
      final double boxHeight = size.height + indicatorPadding + errorPadding;
      // get height of the screen from mediaQuery.
      final double screenHeight = MediaQuery.of(context).size.height;
      // get the ratio to set as max size.
      final double ratio = boxHeight / screenHeight;
      maxSize = ratio.clamp(.1, .9);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: maxSize,
      initialChildSize: maxSize,
      builder: (context, scrollController) {
        return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: MeasureSize(
              onChange: _setMaxChildSize,
              child: SafeArea(
                top: false,
                maintainBottomViewPadding: true,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cardTheme: Theme.of(context).cardTheme.copyWith(elevation: 0.75),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              widget.icon,
                              size: 32,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 8),
                            ),
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 8)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void showBottomSheet({required BuildContext context, required Widget child}) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return child;
      },
    );
