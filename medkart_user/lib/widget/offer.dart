import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopOffersPage extends StatelessWidget {
  final List<Map<String, String>> offers = [
    {"image": "assets/mm2.jpg", "title": "Wrogn, UCB", "discount": "60-80% Off"},
    {"image": "assets/mm2.jpg", "title": "Top Offers", "discount": "Min. 70% Off"},
    {"image": "assets/mm2.jpg", "title": "Kurta Sets", "discount": "Min. 70% Off"},
    {"image": "assets/mm2.jpg", "title": "Luggage", "discount": "From ₹249"},
    {"image": "assets/mm2.jpg", "title": "Jackets", "discount": "Under ₹499"},
    {"image": "assets/mm2.jpg", "title": "ASICS, Skechers", "discount": "Min. 55% Off"},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get screen width
    final cardWidth = screenWidth / 3; // Adjust the width for each card dynamically (3 cards per screen)
    final cardHeight = 250.0; // Fixed height for each card

    return Card(  // Wrap the entire section in a Card for better styling
      elevation: 8,  // Set the elevation for shadow effect
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),  // Adjust the margin
      child: Padding(
        padding: EdgeInsets.all(10),  // Add padding around the Card content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for "Top Offer" text and "View All" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Offer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Add your "View All" button action here
                    print('View All clicked');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,  // Make sure the row takes the least space
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(color: Colors.blue),
                      ),
                      SizedBox(width: 5),  // Add space between text and icon
                      Icon(
                        Icons.arrow_forward,  // Use the arrow icon or any other icon you prefer
                        color: Colors.blue,
                        size: 20,  // Adjust the size of the icon
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10), // Space between the header and carousel
            // Horizontal scrollable offers
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              child: Row(
                children: offers.map((offer) {
                  return SizedBox(
                    width: cardWidth, // Dynamic width based on the screen size
                    height: cardHeight, // Fixed height
                    child: Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 4), // Small horizontal spacing
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.asset(
                              offer["image"]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            offer["title"]!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            offer["discount"]!,
                            style: TextStyle(color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
