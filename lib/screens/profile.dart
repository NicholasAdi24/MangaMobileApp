import 'package:flutter/material.dart';
import 'home.dart'; // Import halaman "home.dart"
import 'topmanga.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, String>> teamMembers = [
    {
      'Nama': 'Nicholas Priyambodo Adi',
      'NIM': '21120121120026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 243, 33, 61),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Navigasi ke halaman "home.dart" saat tombol "Home" ditekan
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Gambar latar belakang dengan scale setengah halaman dan opacity 0.5
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    image: NetworkImage(
                      'https://media-assets-ggwp.s3.ap-southeast-1.amazonaws.com/2023/06/Karakter-Utama-Anime-Bocchi-The-Rock-featured-640x360.jpg',
                    ),
                  ),
                  color:
                      const Color.fromARGB(255, 255, 252, 252).withOpacity(0.5),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        'https://instagram.fcgk29-1.fna.fbcdn.net/v/t51.2885-19/376757276_1047059899803854_6661742496900313236_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fcgk29-1.fna.fbcdn.net&_nc_cat=102&_nc_ohc=QxwBD_YteU4AX-6DkWR&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfCVYxezoBPSbvK3wHybZ_JlBsBUP-eG0sbv6bgGfUNMSQ&oe=65667A62&_nc_sid=8b3546',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                for (var member in teamMembers)
                  Column(
                    children: [
                      Text(
                        '${member['Nama']}',
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${member['NIM']}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Kredit dan logo MangaDex
          Positioned(
            bottom: 8.0,
            child: Column(
              children: [
                const SizedBox(height: 4.0),
                Image.network(
                  'https://avatars.githubusercontent.com/u/100574686?s=200&v=4',
                  height: 30.0,
                ),
                const Text(
                  'using API: ',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                const Text(
                  'api.mangadex.org',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ],
            ),
          ),
        ],
      ),
      // Tambahkan bottomNavigationBar untuk navbar
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: 2, // Index kedua (Profile) dipilih awal
        onTap: (index) {
          if (index == 0) {
            // Navigasi ke halaman Home
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const HomePage(),
            ));
          } else if (index == 2) {
            // Tidak perlu tindakan tambahan (kita sudah ada di halaman Profile)
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TopMangaPage()),
            );
          }
        },
      ),
    );
  }
}
