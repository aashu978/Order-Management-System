import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopOfferCarousel extends StatefulWidget {
  @override
  _TopOfferCarouselState createState() => _TopOfferCarouselState();
}

class _TopOfferCarouselState extends State<TopOfferCarousel> {
  List<String> imageUrls = [];  // List to store image URLs

  // Function to fetch image URLs from the backend API
  Future<void> _fetchImages() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/images/ws_code/1234'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          // Extract image URLs and store them in the list
          imageUrls = data
              .map<String>((item) => item['url'])
              .where((url) => url.isNotEmpty) // Ensure the URL is not empty
              .toList();
        });
      } else {
        print('Failed to fetch images, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchImages();  // Fetch images when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        imageUrls.isEmpty
            ? Center(child: CircularProgressIndicator())  // Loading indicator while images are being fetched
            : CarouselSlider(
          items: imageUrls.map((url) {
            return Image.network(
              url,  // Use the fetched image URL
              fit: BoxFit.cover,
            );
          }).toList(),
          options: CarouselOptions(
            height: 300.0,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
