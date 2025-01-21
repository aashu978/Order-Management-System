import 'package:flutter/material.dart';
import 'package:medkart_user/screen/prodcut.dart';
import 'package:medkart_user/widget/spot_light.dart';
import '../widget/footer.dart';
import '../widget/medicine_store.dart';
import '../widget/offer.dart';
import '../widget/top_offer_carousel.dart';

class HomePage extends StatelessWidget {
  final String pageName;

  const HomePage({Key? key, required this.pageName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        toolbarHeight: 100, // Custom height for the AppBar
        titleSpacing: 10, // Adjust spacing for the title
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the home page when logo is tapped
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(pageName: 'Home'),
                  ),
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/mm2.jpg', // Replace with your logo asset
                    height: 50,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Medkart\nPharmacy',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            // Search Bar
            Expanded(
              child: Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onSubmitted: (query) {
                    // Handle search query submission
                    print('Search query: $query');
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Sign In Button with Icon
          TextButton.icon(
            onPressed: () {
              print('Sign In clicked');
            },
            icon: Icon(Icons.login, color: Colors.white),
            label: Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
          // Cart Button with Icon
          TextButton.icon(
            onPressed: () {
              print('Cart clicked');
            },
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            label: Text('Cart', style: TextStyle(color: Colors.white)),
          ),
          // Orders Button with Icon
          TextButton.icon(
            onPressed: () {
              print('Orders clicked');
            },
            icon: Icon(Icons.list_alt, color: Colors.white),
            label: Text('Orders', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap entire body in SingleChildScrollView
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ProdcutScreen(),

            SizedBox(height: 10),
            // TopOfferCarousel(),
            // TopOffersPage(),
            // MedicineStore(),
            // SpotLight(),
            // Footer(),
            // SizedBox(height: 5,)
          ],
        ),
      ),
    );
  }
}
