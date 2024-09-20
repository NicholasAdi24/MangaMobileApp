import 'package:flutter/material.dart';
import 'home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    // Mendapatkan reaction dari API allreactions
    fetchReaction();
  }

  Future<void> fetchReaction() async {
    final response =
        await http.get(Uri.parse('https://api.otakugifs.xyz/gif/allreactions'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<String> reactions = List<String>.from(data['reactions']);

      // Generate a random index
      final random = Random();
      final int randomIndex = random.nextInt(reactions.length);

      final selectedReaction = reactions.isNotEmpty
          ? reactions[randomIndex]
          : 'smile'; // Default jika array kosong

      // Mendapatkan gambar dari API dengan menggunakan reaction terpilih
      fetchImage(selectedReaction);
    } else {
      // Handle error
      print('Failed to load reactions');
    }
  }

  Future<void> fetchImage(String reaction) async {
    final response = await http
        .get(Uri.parse('https://api.otakugifs.xyz/gif?reaction=$reaction'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final imageUrl = data['url'];
      setState(() {
        this.imageUrl = imageUrl;
      });
    } else {
      // Handle error
      print('Failed to load image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                imageUrl, // URL gambar dari API
                fit: BoxFit.cover, // Membuat gambar memenuhi space yang ada
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'DBS\nmanga app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman Home jika tombol "GET START" ditekan
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('GET START'),
            ),
          ],
        ),
      ),
    );
  }
}
