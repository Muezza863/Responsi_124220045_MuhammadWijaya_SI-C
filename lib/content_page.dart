import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:responsi/detail_page.dart';
import 'fav_page.dart';

class ContentPage extends StatelessWidget {
  final String username;

  ContentPage({required this.username});

  Future<List<Map<String, dynamic>>> fetchData() async {
    // Panggil API
    String url = 'https://restaurant-api.dicoding.dev/list';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Parsing respons JSON
      final jsonResponse = jsonDecode(response.body);

      // Ambil data dari key "restaurants" yang berupa array
      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('restaurants')) {
        return List<Map<String, dynamic>>.from(jsonResponse['restaurants']);
      } else {
        throw Exception('Unexpected JSON structure');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hallo, ${username}"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              // Navigasi ke halaman favorit
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritePage()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey,
          ),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data available'));
              } else {
                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        // Aksi saat card diklik
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              id: item['id'], // String
                              pictureId: item['pictureId'], // String
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar
                            if (item['pictureId'] != null)
                              Padding(
                                padding: EdgeInsets.only(left: 8, top: 15, right: 8),
                                child:
                                  Image.network(
                                    "https://restaurant-api.dicoding.dev/images/small/${item['pictureId']}",
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: Colors.grey,
                                        child: Center(
                                          child: Icon(Icons.broken_image, size: 50),
                                        ),
                                      );
                                    },
                                  ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    item['name'] ?? 'No Title',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    child: Icon(Icons.arrow_forward_sharp),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
