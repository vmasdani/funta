import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:funta/db.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

Future main() async {
  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");

  Hive.registerAdapter(NoteAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Note Taker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: (() async {
                  return (await Hive.openBox<Note>('notes')).values;
                })(),
                builder: (BuildContext context,
                    AsyncSnapshot<Iterable<Note>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container(
                      child: Column(
                        children: (snapshot.data?.map((n) {
                              return Container(
                                child: Column(children: [
                                  Text('Created: ${(() {
                                    try {
                                      return '${DateFormat.yMMMEd().add_jms().format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              n.created ?? 0,
                                            ),
                                          )} ${DateTime.fromMillisecondsSinceEpoch(
                                        n.created ?? 0,
                                      ).timeZoneName}';
                                    } catch (e) {
                                      return 'None';
                                    }
                                  })()}')
                                ]),
                              );
                            })?.toList() ??
                            []),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() async {
          print(
              'Adding Note, now: ${(await Hive.openBox<Note>('notes')).values?.length}');
          await (await Hive.openBox<Note>('notes')).add(
            Note()
              ..uuid = const Uuid().v4()
              ..created = DateTime.now().millisecondsSinceEpoch
              ..updated = DateTime.now().millisecondsSinceEpoch
              ..title = 'New Note ${DateFormat.yMMMEd().add_jms().format(
                    DateTime.now(),
                  )}',
          );
          setState(() {});
        }),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
