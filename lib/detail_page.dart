import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String pictureId;

  DetailPage({required this.id, required this.pictureId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;

  Future<void> toggleFavorite(String id, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorites') ?? [];

      if (isFavorite) {
        // Jika sudah favorit, hapus dari daftar
        favorites.remove(id);
        setState(() {
          isFavorite = false;
        });
        prefs.setStringList('favorites', favorites);
        _showSnackbar('Removed from favorites!', Colors.red);
      } else {
        // Tambahkan ke daftar favorit
        favorites.add(id);
        prefs.setStringList('favorites', favorites);
        setState(() {
          isFavorite = true;
        });
        _showSnackbar('Added to favorites!', Colors.green);
      }
    } catch (e) {
      _showSnackbar('Error updating favorites!', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchDetail() async {
    String url = 'https://restaurant-api.dicoding.dev/detail/${widget.id}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['error'] == false && jsonResponse.containsKey('restaurant')) {
          return jsonResponse['restaurant'];
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception('Failed to fetch data. HTTP Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error while fetching detail: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Detail'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error occurred:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar
                  if (data['pictureId'] != null)
                    Image.network(
                      "https://restaurant-api.dicoding.dev/images/medium/${data['pictureId']}",
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
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Restoran
                          Text(
                            data['name'] ?? 'No Title',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          // Kota
                          Text(
                            'City: ${data['city'] ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          // Rating
                          Text(
                            'Rating: ${data['rating']?.toStringAsFixed(1) ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => toggleFavorite(widget.id, data['name']),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Deskripsi
                  Text(
                    data['description'] ?? 'No Description Available',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // Tombol URL
                  if (data['website'] != null)
                    ElevatedButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(data['website']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch ${data['website']}')),
                          );
                        }
                      },
                      child: Text('Visit Website'),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
