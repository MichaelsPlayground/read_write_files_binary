import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Read & write files binary'),
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
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // _incrementCounter;

          // write a textfile to internal storage to have a file to read from
          String ptString = 'abcdefghijklmnopABCDEFGHIJKLMNOP12345'; // 37 chars
          print('write to file: ' + ptString);
          Uint8List pt = createUint8ListFromString(ptString);
          print('pt: ' + bytesToHex(pt) + ' Length: ' + pt.length.toString());
          _write(ptString);
          String ptLoaded = await _read();
          print('ptLoaded: ' + ptLoaded);

          // now we have file to work with
          // https://api.dart.dev/be/137510/dart-io/RandomAccessFile-class.html
          Directory directory = await getApplicationDocumentsDirectory();
          File file = File('${directory.path}/my_file.txt');
          print('RandomAccessFile SYNC modus');
          RandomAccessFile raf = file.openSync(mode: FileMode.read);
          raf.setPositionSync(4); // from position 5 (count starting at 0
          Uint8List data = raf.readSync(7); // reading 7 bytes
          print('data ab 4 insgesamt 7 bytes: ' + bytesToHex(data));
          data = raf.readSync(3);
          print('data 3 weitere bytes: ' + bytesToHex(data));
          raf.closeSync();

          print('RandomAccessFile ASYNC modus');
          RandomAccessFile rafAsync = await file.open(mode: FileMode.read);
          var fileLength = await file.length();
          print('file length: ' + fileLength.toString());
          await rafAsync.setPosition(4); // from position 5 (count starting at 0
          Uint8List dataAsync = await rafAsync.read(7); // reading 7 bytes
          print('data ab 4 insgesamt 7 bytes: ' + bytesToHex(dataAsync));
          dataAsync = await rafAsync.read(3);
          print('data 3 weitere bytes: ' + bytesToHex(dataAsync));
          Uint8List dataAsync2 = await rafAsync.read(2);
          print('data 2 weitere bytes: ' + bytesToHex(dataAsync2));
          rafAsync.close();

          // write bytes to a new file
          print('write bytes to a new file');
          File fileW = File('${directory.path}/my_file_w.txt');
          RandomAccessFile rafWAsync = await fileW.open(mode: FileMode.write);
          await rafWAsync.writeFrom(dataAsync);
          await rafWAsync.writeFrom(dataAsync2);
          await rafWAsync.flush();
          await rafWAsync.close();

          // read data
          print('read data from new file');
          File fileR = File('${directory.path}/my_file_w.txt');
          RandomAccessFile rafRAsync = await fileR.open(mode: FileMode.read);
          var fileRLength = await fileR.length();
          print('fileR length: ' + fileRLength.toString());
          await rafRAsync.setPosition(0); // from position 0
          Uint8List dataRAsync = await rafRAsync.read(fileRLength); // reading all bytes
          print('dataRAsync ab 0: ' + bytesToHex(dataRAsync));



        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  String bytesToHex(Uint8List data) {
    return hex.encode(data);
  }

  Uint8List createUint8ListFromString(String s) {
    var ret = new Uint8List(s.length);
    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }
    return ret;
  }

  // Writing to a text file
  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsString(text);
  }

  // Reading from a text file
  Future<String> _read() async {
    String text = '';
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/my_file.txt');
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

}
