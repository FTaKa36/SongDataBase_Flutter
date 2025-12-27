import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.initDb();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "SF Pro Display",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final pages = [
    InputPage(),
    DisplayPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.add), label: "Input Data"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: "Display Data"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController titleC = TextEditingController();
  final TextEditingController durasiC = TextEditingController();
  final TextEditingController bandC = TextEditingController();
  final TextEditingController albumC = TextEditingController();
  final TextEditingController releaseC = TextEditingController();

  String? selectedGenre;
  String? selectedRecord;

  final List<String> genreItems = ["Pop", "Rock", "Jazz", "Dangdut"];
  final List<String> recordItems = ["Akustik", "Studio"];

  Future<void> _add() async {
    if (titleC.text.isEmpty ||
        durasiC.text.isEmpty ||
        selectedGenre == null ||
        selectedRecord == null) return;

    await DbHelper.insertLagu({
      'title': titleC.text,
      'duration': int.parse(durasiC.text),
      'genre': selectedGenre,
      'record_type': selectedRecord,
      'band': bandC.text,
      'album': albumC.text,
      'release_date': releaseC.text,
    });

    _clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Berhasil Ditambahkan!")));
  }

  void _clear() {
    titleC.clear();
    durasiC.clear();
    bandC.clear();
    albumC.clear();
    releaseC.clear();
    selectedGenre = null;
    selectedRecord = null;
    setState(() {});
  }

  InputDecoration deco(String txt) =>
      InputDecoration(labelText: txt, border: OutlineInputBorder());

  Widget datePicker() => TextField(
        controller: releaseC,
        readOnly: true,
        decoration: deco("Tanggal Rilis"),
        onTap: () async {
          final pick = await showDatePicker(
              context: context,
              firstDate: DateTime(1980),
              lastDate: DateTime.now(),
              initialDate: DateTime.now());
          if (pick != null) {
            releaseC.text = "${pick.day}-${pick.month}-${pick.year}";
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Lagu"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(controller: titleC, decoration: deco("Nama Lagu")),
            const SizedBox(height: 10),
            TextField(
              controller: durasiC,
              keyboardType: TextInputType.number,
              decoration: deco("Durasi (menit)"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              decoration: deco("Genre"),
              items: genreItems
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: selectedGenre,
              onChanged: (v) => setState(() => selectedGenre = v),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              decoration: deco("Record Type"),
              items: recordItems
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: selectedRecord,
              onChanged: (v) => setState(() => selectedRecord = v),
            ),
            const SizedBox(height: 10),
            TextField(controller: bandC, decoration: deco("Band")),
            const SizedBox(height: 10),
            TextField(controller: albumC, decoration: deco("Album")),
            const SizedBox(height: 10),
            datePicker(),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              child: const Text("Tambah Lagu"),
              onPressed: _add,
            )
          ],
        ),
      ),
    );
  }
}

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  List<Map<String, dynamic>> list = [];

  Future<void> load() async {
    list = (await DbHelper.getAllLagu()).reversed.toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Lagu"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: list.isEmpty
          ? const Center(child: Text("Tidak ada data"))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final x = list[i];
                return Dismissible(
                  key: ValueKey(x['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    await DbHelper.deleteLagu(x['id']);
                    load();
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(18),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading:
                        const Icon(Icons.music_note, color: Colors.red, size: 30),
                    title: Text(x['title']),
                    subtitle:
                        Text("${x['band']} • ${x['duration']} menit • ${x['genre']}"),
                  ),
                );
              }),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          "I made this for my training and I made this with helping from AI too",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

