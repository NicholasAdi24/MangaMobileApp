import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'profile.dart'; // Import file profile.dart
// Sesuaikan dengan nama file dan path TopMangaPage

class TopMangaPage extends StatefulWidget {
  const TopMangaPage({Key? key}) : super(key: key);

  @override
  _TopMangaPageState createState() => _TopMangaPageState();
}

class _TopMangaPageState extends State<TopMangaPage> {
  List<Map<String, dynamic>> topMangaList = [];
  int _currentIndex = 1; // Sesuaikan dengan index halaman Top Manga

  @override
  void initState() {
    super.initState();
    fetchTopManga();
  }

  Future<void> fetchTopManga() async {
    final response =
        await http.get(Uri.parse('https://api.jikan.moe/v4/top/manga'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> topMangaData = data['data'] ?? [];

      setState(() {
        topMangaList.addAll(List<Map<String, dynamic>>.from(topMangaData));
      });
    } else {
      print('Failed to load top manga: ${response.statusCode}');
      throw Exception('Failed to load top manga');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top Manga',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color.fromARGB(255, 243, 33, 61),
      ),
      body: topMangaList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: topMangaList.length,
              itemBuilder: (context, index) {
                final mangaData = topMangaList[index];
                final mangaTitle = mangaData['title'] ?? 'No Title';
                final mangaImage =
                    mangaData['images']['jpg']['large_image_url'] ?? '';
                final rank = index + 1;

                return Card(
                  child: ListTile(
                    title: Column(
                      children: [
                        Text(
                          'Rank $rank: $mangaTitle',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Image.network(
                          mangaImage,
                          width: 150,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle tap on the manga item if needed
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (_currentIndex == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Top Manga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
