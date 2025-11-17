import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// =============================================================
/// SERVICE: FileService - operasi dasar baca/tulis file JSON
/// =============================================================
class FileService {
  Future<Directory> get documentaryDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  // Simpan data ke file (String)
  Future<File> writeFile(String fileName, String content) async {
    final Directory dir = await documentaryDirectory;
    final file = File(path.join(dir.path, fileName));
    return file.writeAsString(content);
  }

  // Baca data dari file
  Future<String>readFile(String fileName) async {
    try {
      final Directory dir = await documentaryDirectory;
      final file = File(path.join(dir.path, fileName));
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  // Simpan object sebagai JSON
  Future<File> writeJson(String fileName, Map<String, dynamic> json) async {
    final String content = jsonEncode(json);
    return writeFile(fileName, content);
  }

  // Baca JSON dari file
  Future<Map<String, dynamic>> readJson(String fileName) async {
    try{
      final String content = await readFile(fileName);
      return jsonDecode(content);
    } catch (e) {
      return {};
    }
  }

  // Cek apakah file ada
  Future<bool> fileExists(String fileName) async {
    final Directory dir = await documentaryDirectory;
    final File file = File(path.join(dir.path, fileName));
    return file.exists();
  }

  // Hapus file
  Future<void> deleteFile(String fileName) async {
    try {
      final Directory dir = await documentaryDirectory;
      final File file = File(path.join(dir.path, fileName));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}

/// =============================================================
/// SERVICE: UserDataService - untuk menyimpan dan membaca user data
/// =============================================================
class UserDataService {
  final FileService _fileService = FileService();
  final String _fileName = 'user_data.json';

  Future<void> saveUserData({
    required String name,
    required String email,
    int? age,
  }) async {
    final Map<String, dynamic> userData = {
      'name': name,
      'email': email,
      'age': age ?? 0,
      'last_update' : DateTime.now().toIso8601String(),
    };
    await _fileService.writeJson(_fileName, userData);
  }

  Future<Map<String, dynamic>?> readUserData() async {
    final exists = await _fileService.fileExists(_fileName);
    if (!exists) return null;

    final Map<String, dynamic> data = await _fileService.readJson(_fileName);
    return data.isNotEmpty ? data : null; 
  }

  Future<void> deleteUserData() async {
    await _fileService.deleteFile(_fileName);
  }

  Future<bool> hasUserData() async {
    return await _fileService.fileExists(_fileName);
  }
}

/// =============================================================
/// MAIN APP
/// =============================================================
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Data JSON Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: UserProfilePage(),
    );
  }
}

/// =============================================================
/// UI: UserProfilePage
/// =============================================================
class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Perbaikan nama variabel: jangan ada underscore di tengah tipe
  final UserDataService _userService = UserDataService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  Map<String, dynamic>? _savedData;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from JSON file
  Future<void> _loadUserData() async {
    final data = await _userService.readUserData();
    setState(() {
      _savedData = data;
    });
  }

  /// Simpan data ke JSON file
  Future<void> _saveUserData() async {
    await _userService.saveUserData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      age: int.tryParse(_ageController.text),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved successfully')),
    );

    await _loadUserData();
  }

  /// Hapus JSON file
  Future<void> _deleteUserData() async {
    await _userService.deleteUserData();

    setState(() => _savedData = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User data deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile (JSON File)')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // FORM INPUT
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ), // InputDecoration
            ), // TextField
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ), // InputDecoration
            ), // TextField
            SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Usia',
                border: OutlineInputBorder(),
              ), // InputDecoration
              keyboardType: TextInputType.number,
            ), // TextField
            SizedBox(height: 20),
            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                  onPressed: _saveUserData,
                ), // ElevatedButton.icon
                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _deleteUserData,
                ),
              ],
            ),

            SizedBox(height: 30),
            Divider(),

            // Tampilan data yang disimpan
            _savedData == null
                ? Text('Belum ada data tersimpan.',
                style: TextStyle(color: Colors.grey),
              )
            :  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📁Data Tersimpan:',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                _buildDataRow('Nama', _savedData!['name']),
                _buildDataRow('Email', _savedData!['email']),
                _buildDataRow('Usia', _savedData!['age'].toString()),
                _buildDataRow(
                  'Update Terakhir',
                  _savedData!['last_update'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper to display 1 row of data
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ), // Row
    ); // Padding
  }
}