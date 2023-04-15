import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_gen/qr_generate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _defaultLightColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.purple);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.purple, brightness: Brightness.dark);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            useMaterial3: true,
            textTheme: GoogleFonts.ralewayTextTheme(
              Theme.of(context).textTheme,
            )),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            textTheme: GoogleFonts.ralewayTextTheme(
              Theme.of(context).textTheme,
            )),
        themeMode: ThemeMode.light,
        home: const MyHomePage(title: 'QR Code Generator'),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController userTextInput = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: userTextInput,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your text/link to generate QR',
              ),
              keyboardType: TextInputType.multiline,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) {
                    return QrGenerate(userTextInput);
                  }),
                ),
              );
            },
            child: const Text('Generate QR'),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Scan QR',
        child: const Icon(Icons.qr_code_scanner),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
