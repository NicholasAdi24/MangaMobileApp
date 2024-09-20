import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final String mangaId;
  final String fileName;
  final String title;

  const DetailPage({
    Key? key,
    required this.mangaId,
    required this.fileName,
    required this.title,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String description = 'Loading description...';
  late List<Chapter> chapters = [];
  List<String> genres = [];
  bool _isSortingAscending = true;

  @override
  void initState() {
    super.initState();
    fetchDescription();
    fetchChapterList();
  }

  Future<void> fetchDescription() async {
    final response = await http.get(
      Uri.parse('https://api.mangadex.org/manga/${widget.mangaId}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Fetch and set description
      final String descriptionText =
          data['data']['attributes']['description']['en'];
      setState(() {
        description = descriptionText;
      });

      // Fetch and set genres
      final List<dynamic> tags = data['data']['attributes']['tags'] ?? [];
      final List<String> genreList = tags
          .where((tag) =>
              tag['type'] == 'tag' &&
              tag['attributes'] != null &&
              tag['attributes']['group'] == 'genre')
          .map<String>((tag) => tag['attributes']['name']['en'])
          .toList();
      setState(() {
        genres = genreList;
      });
    } else {
      setState(() {
        description = 'Failed to load description';
      });
    }
  }

  Future<void> fetchChapterList() async {
    final response = await http.get(
      Uri.parse('https://api.mangadex.org/manga/${widget.mangaId}/aggregate'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Chapter> chapterList = [];

      data['volumes'].forEach((volumeKey, volumeData) {
        volumeData['chapters'].forEach((chapterKey, chapterData) async {
          final List<String> others = chapterData['others'] != null
              ? List<String>.from(chapterData['others'])
              : [];

          // Cek status "already read" dari SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final isRead = prefs.getBool(chapterData['id']) ?? false;

          chapterList.add(
            Chapter(
              id: chapterData['id'],
              chapter: chapterData['chapter'],
              others: others,
              isRead: isRead,
            ),
          );
        });
      });

      setState(() {
        chapters = chapterList;
      });
    } else {
      // Handle error when fetching chapters
      print('Failed to load chapters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 243, 33, 61),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Tempatkan logika refresh Anda di sini
          await fetchDescription();
          await fetchChapterList();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const Text(''),
              Image.network(
                'https://mangadex.org/covers/${widget.mangaId}/${widget.fileName}',
                width: 500,
                height: 450,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(description),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Genres:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(genres.join(', ')),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Sort chapters descending (besar ke kecil)
                      setState(() {
                        _isSortingAscending = false;
                        chapters.sort((a, b) => double.parse(b.chapter)
                            .compareTo(double.parse(a.chapter)));
                      });
                    },
                    child: const Text('Sort Descending'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Sort chapters ascending (kecil ke besar)
                      setState(() {
                        _isSortingAscending = true;
                        chapters.sort((a, b) => double.parse(a.chapter)
                            .compareTo(double.parse(b.chapter)));
                      });
                    },
                    child: const Text('Sort Ascending'),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Chapters:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: chapters.map((chapter) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to LanguagePage when a chapter is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LanguagePage(
                            chapterTitle: 'Chapter ${chapter.chapter}',
                            chapterIds: [chapter.id, ...chapter.others],
                          ),
                        ),
                      ).then((_) {
                        // Set chapter as read when navigating back
                        setState(() {
                          chapter.isRead = true;
                        });
                      });
                    },
                    child: Card(
                      color: chapter.isRead ? Colors.grey[300] : null,
                      child: ListTile(
                        title: Text('Chapter ${chapter.chapter}'),
                        subtitle:
                            chapter.isRead ? const Text('Already Read') : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Chapter {
  final String id;
  final String chapter;
  final List<String> others;
  bool isRead;

  Chapter({
    required this.id,
    required this.chapter,
    required this.others,
    this.isRead = false,
  });

  // Konversi Chapter ke Map untuk disimpan di SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapter': chapter,
      'others': others,
      'isRead': isRead,
    };
  }

  // Buat Chapter dari Map yang diperoleh dari SharedPreferences
  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      chapter: map['chapter'],
      others: List<String>.from(map['others']),
      isRead: map['isRead'],
    );
  }
}
