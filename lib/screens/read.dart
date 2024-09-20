import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReadPage extends StatefulWidget {
  final String baseUrl;
  final String chapterHash;
  final List<String> chapterData;

  const ReadPage({
    Key? key,
    required this.baseUrl,
    required this.chapterHash,
    required this.chapterData,
  }) : super(key: key);

  @override
  _ReadPageState createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  bool isVertical = true;
  late String baseUrl;
  late String chapterHash;
  late List<String> chapterData;

  @override
  void initState() {
    super.initState();
    // Inisialisasi nilai baseUrl, chapterHash, dan chapterData
    baseUrl = widget.baseUrl;
    chapterHash = widget.chapterHash;
    chapterData = List.from(widget.chapterData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isVertical ? buildVerticalView() : buildHorizontalView(),
          Positioned(
            top: 40,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isVertical = !isVertical;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(10),
                child: isVertical
                    ? const Icon(Icons.swap_horiz)
                    : const Icon(Icons.swap_vert),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVerticalView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        itemCount: chapterData.length,
        separatorBuilder: (context, index) => SizedBox(height: 0),
        itemBuilder: (context, index) {
          final imageUrl = '$baseUrl/data/$chapterHash/${chapterData[index]}';
          return CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          );
        },
      ),
    );
  }

  Widget buildHorizontalView() {
    return PhotoViewGallery.builder(
      itemCount: chapterData.length,
      builder: (context, index) {
        final imageUrl = '$baseUrl/data/$chapterHash/${chapterData[index]}';
        return PhotoViewGalleryPageOptions(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      scrollPhysics: BouncingScrollPhysics(),
      backgroundDecoration: BoxDecoration(
        color: Colors.black,
      ),
      pageController: PageController(),
      onPageChanged: (index) {},
    );
  }

  Future<void> _loadData() async {
    try {
      final apiUrl =
          'https://api.mangadex.org/at-home/server/${chapterData.first}';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> chapterDataResponse =
            json.decode(response.body);

        setState(() {
          baseUrl = chapterDataResponse['baseUrl'];
          chapterHash = chapterDataResponse['chapter']['hash'];
          chapterData =
              List<String>.from(chapterDataResponse['chapter']['data']);
        });
      } else {
        print('Failed to load chapter data');
        // Handle error jika diperlukan
      }
    } catch (error) {
      print('Error refreshing data: $error');
      // Handle error jika diperlukan
    }
  }
}
