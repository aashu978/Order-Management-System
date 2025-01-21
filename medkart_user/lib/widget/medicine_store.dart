import 'package:flutter/material.dart';

class MedicineStore extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Pudin Hara Capsule 10\'s',
      'price': '₹30',
      'discount': null,
      'image': 'assets/mm2.jpg',
    },
    {
      'name': 'Digene (Orange) Tablet 15\'s',
      'price': '₹26.28',
      'discount': '10% off',
      'image': 'assets/mm2.jpg',
    },
    {
      'name': 'Crocin Pain Relief Tablet 15\'s',
      'price': '₹50',
      'discount': '5% off',
      'image': 'assets/mm2.jpg',
    },
    {
      'name': 'Vicks VapoRub 50g',
      'price': '₹75',
      'discount': null,
      'image': 'assets/mm2.jpg',
    },
    {
      'name': 'Himalaya Liv.52 100\'s',
      'price': '₹150',
      'discount': '15% off',
      'image': 'assets/mm2.jpg',
    },
    {
      'name': 'Zandu Balm 20g',
      'price': '₹40',
      'discount': '5% off',
      'image': 'assets/mm2.jpg',
    },
    {
      'name': 'Vicks Cough Syrup 100ml',
      'price': '₹120',
      'discount': '10% off',
      'image': 'assets/mm2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 6.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Title section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Trending Products',
                    style: TextStyle(
                      fontSize: 18.0,
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
                          'See All',
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
              SizedBox(height: 8.0), // Spacing between title and product list

              // Product list in horizontal scrolling row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Card(
                        elevation: 4.0,
                        child: SizedBox(
                          height: 250,
                          width: MediaQuery.of(context).size.width / 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  product['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  product['price'],
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              if (product['discount'] != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    product['discount'],
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text('Add'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
