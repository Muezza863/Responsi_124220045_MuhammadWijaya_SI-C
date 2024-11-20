import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'detail_page.dart';

class FavoritePage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchFavoriteDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorites') ?? [];

    List<Map<String, dynamic>> favoriteDetails = [];

    // Loop untuk mem-fetch data berdasarkan ID favorit
    for (String id in favoriteIds) {
      final url = 'https://restaurant-api.dicoding.dev/detail/$id';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['error'] == false && jsonResponse.containsKey('restaurant')) {
          final restaurant = jsonResponse['restaurant'];
          favoriteDetails.add({
            'id': restaurant['id'],
            'name': restaurant['name'],
            'city': restaurant['city'],
            'rating': restaurant['rating'].toString(),
            'pictureId': restaurant['pictureId'],
          });
        }
      }
    }
    return favoriteDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Restaurants'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey,
          ),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchFavoriteDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No favorites added',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              } else {
                final favorites = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigasi ke DetailPage dengan ID dan Picture ID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              id: favorite['id'],
                              pictureId: favorite['pictureId'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.only(bottom: 16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Gambar Restoran
                              if (favorite['pictureId'] != null)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://restaurant-api.dicoding.dev/images/small/${favorite['pictureId']}',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    size: 40,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              SizedBox(width: 16.0),
                              // Nama Restoran
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      favorite['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          favorite['city'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Icon(Icons.circle_rounded, size: 7,),
                                        SizedBox(width: 10,),
                                        Text(
                                          "Rating : ",
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          favorite['rating'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
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
