import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WireMockApp());
}

class WireMockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WireMock Cloud Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: UserPage(),
    );
  }
}

class ApiConfig {
  static const String baseUrl = 
    'https://alvi.wiremockapi.cloud';
  static const usersEndpoint = '/users';

  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<dynamic> users = [];
  bool isLoading = false;
  String? errorMessage;
  String? postMessage; // Tambahkan kode berikut untuk menampilkan hasil POST

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // GET users
  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}');

    try {
      final response = await http
        .get(url, headers: ApiConfig.headers)
        .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => users = data);
      } else {
        setState(() => errorMessage = 'Error ${response.statusCode}');
      }
    } catch (e) {
      setState(() => errorMessage = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // POST new user
  Future<void> addUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name & Email cannot be empty!')),
      );
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}');
    final body = jsonEncode({'name': name, 'email': email});

    try {
      final response = await http
          .post(url, headers: ApiConfig.headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> result = jsonDecode(response.body);

        setState(() {
          postMessage = result['message'] ?? 'User successfully added!';
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(postMessage!)));

        _nameController.clear();
        _emailController.clear();
        fetchUsers();
      } else {
        setState(() => postMessage = 'Failed to add user (${response.statusCode})');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(postMessage!)));
      }
    } catch (e) {
      setState(() => postMessage = 'Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(postMessage!)));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WireMock Cloud Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input form
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
              onPressed: addUser,
            ),

            const SizedBox(height: 20),

            // Pesan sukses
            if (postMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  postMessage!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

            const Divider(),
            
            const Text(
              'User List',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ), // Text

            const Divider(),

            // Data list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : users.isEmpty
                          ? const Center(child: Text('No data yet.'))
                          : ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${user['id']}'),
                                  ),
                                  title: Text(user['name']),
                                  subtitle: Text(user['email']),
                                ); // ListTile
                              },
                            ), // ListView.builder
            ), // Expanded
          ],
        ),
      ),
    );
  }
}