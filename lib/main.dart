// main.dart

import 'package:flutter/material.dart';
import 'package:dbs_manga/screens/language.dart';
import 'package:dbs_manga/screens/read.dart';

import 'screens/detail.dart';
import 'screens/home.dart';
import 'screens/splashscreen.dart';

void main() async {
  runApp(const AnimeApp());
}

class AnimeApp extends StatelessWidget {
  const AnimeApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga app',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Set splash screen sebagai halaman pertama
      routes: {
        '/homepage': (context) => const HomePage(),
        '/splashscreen': (context) => const SplashScreen(),
        '/read': ((context) => ReadPage(
              baseUrl: '',
              chapterData: [],
              chapterHash: '',
            )),
        '/language': (context) =>
            const LanguagePage(chapterTitle: '', chapterIds: []),
        '/detail': (context) => const DetailPage(
              mangaId: '',
              fileName: '',
              title: '',
            )
      },
    );
  }
}
