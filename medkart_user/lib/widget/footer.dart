import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal, // Footer background color
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Row for Contact and Quick Links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Contact Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Phone: +123 456 7890',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Email: support@medicine.com',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Quick Links
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Links',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Shop',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'About Us',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Contact',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Social Media Icons
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow Us',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.white), // Facebook icon
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.instagram, color: Colors.white), // Instagram icon
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.twitter, color: Colors.white), // Twitter icon
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Divider
          SizedBox(height: 20),
          Divider(color: Colors.white),

          // Copyright Text
          SizedBox(height: 10),
          Text(
            '© 2025 Medicine Store. All Rights Reserved.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
