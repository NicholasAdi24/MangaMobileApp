import 'package:flutter/material.dart';
import 'read.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LanguagePage extends StatelessWidget {
  final String chapterTitle;
  final List<String> chapterIds;

  const LanguagePage(
      {super.key, required this.chapterTitle, required this.chapterIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Languages for $chapterTitle'),
        backgroundColor: const Color.fromARGB(255, 243, 33, 61),
      ),
      body: ListView.builder(
        itemCount: chapterIds.length,
        itemBuilder: (context, index) {
          final chapterId = chapterIds[index];

          return FutureBuilder(
            future: fetchChapterData(chapterId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: ListTile(
                    title: Text('Loading...'),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Card(
                  child: ListTile(
                    title: Text('Error loading data'),
                  ),
                );
              } else {
                final Map<String, dynamic>? chapterData =
                    snapshot.data as Map<String, dynamic>?;

                if (chapterData != null &&
                    chapterData['data'] != null &&
                    chapterData['data']['attributes'] != null) {
                  final attributes = chapterData['data']['attributes'];
                  final translatedLanguage =
                      attributes['translatedLanguage'] ?? 'Unknown';

                  return Card(
                    child: ListTile(
                      title: Text(chapterTitle),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: $chapterId'),
                          Text('Language: $translatedLanguage'),
                        ],
                      ),
                      onTap: () async {
                        final apiUrl =
                            'https://api.mangadex.org/at-home/server/$chapterId';

                        final response = await http.get(Uri.parse(apiUrl));

                        if (response.statusCode == 200) {
                          final Map<String, dynamic> chapterData =
                              json.decode(response.body);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadPage(
                                baseUrl: chapterData['baseUrl'],
                                chapterHash: chapterData['chapter']['hash'],
                                chapterData: List<String>.from(
                                    chapterData['chapter']['data']),
                              ),
                            ),
                          );
                        } else {
                          print('Failed to load chapter data');
                        }
                      },
                    ),
                  );
                } else {
                  return const Card(
                    child: ListTile(
                      title: Text('Data not found'),
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchChapterData(String chapterId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.mangadex.org/chapter/$chapterId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            'Failed to load chapter data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load chapter data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load chapter data');
    }
  }
}
