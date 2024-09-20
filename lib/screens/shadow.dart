import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MangaData {
  final String title;
  final String description;
  final String imageUrl;

  MangaData({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory MangaData.fromJson(Map<String, dynamic> json) {
    final attributes = json['data']['attributes'];
    return MangaData(
      title: attributes['title']['ja-ro'] ?? 'No Title',
      description: attributes['description']['en'] ?? 'No Description',
      imageUrl:
          'https://mangadex.org/covers/77bee52c-d2d6-44ad-a33a-1734c1fe696a/143ca3b0-a980-4d01-bec3-7404f01d377d.jpg.512.jpg',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga App',
      key: const Key('mangaApp'),
      home: FutureBuilder<MangaData>(
        future: fetchMangaData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error.toString()}');
          } else {
            return MyHomePage(
              title: 'Manga Details',
              mangaData: snapshot.data!,
            );
          }
        },
      ),
    );
  }
}

Future<MangaData> fetchMangaData() async {
  final Uri url = Uri.parse(
      'https://api.mangadex.org/manga/77bee52c-d2d6-44ad-a33a-1734c1fe696a');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return MangaData.fromJson(data);
  } else {
    throw Exception(
        'Failed to load manga data. Status code: ${response.statusCode}');
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final MangaData mangaData;

  const MyHomePage({super.key, required this.title, required this.mangaData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                mangaData.imageUrl,
                height: 200, // Set the height as needed
                width: 150, // Set the width as needed
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Title: ${mangaData.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Description: ${mangaData.description}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chapters:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder<List<Chapter>>(
                future: fetchChapterList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error.toString()}');
                  } else {
                    List<Chapter> chapters = snapshot.data!;
                    return ListView.builder(
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text('Chapter ${chapters[index].chapter}'),
                            subtitle: Text('ID: ${chapters[index].id}'),
                            onTap: () {
                              // Handle chapter tap
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Chapter>> fetchChapterList() async {
    final Uri url = Uri.parse(
        'https://api.mangadex.org/manga/77bee52c-d2d6-44ad-a33a-1734c1fe696a/aggregate');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Chapter> chapters = [];
      data['volumes'].forEach((volumeKey, volumeData) {
        volumeData['chapters'].forEach((chapterKey, chapterData) {
          chapters.add(
            Chapter(
              id: chapterData['id'],
              chapter: chapterData['chapter'],
            ),
          );
        });
      });
      return chapters;
    } else {
      throw Exception(
          'Failed to load manga chapters. Status code: ${response.statusCode}');
    }
  }
}

class Chapter {
  final String id;
  final String chapter;

  Chapter({required this.id, required this.chapter});
}
