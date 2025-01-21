import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medkart_user/widget/all_product.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/about.dart';
import '../screen/contact.dart';
import '../screen/prodcut.dart';

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

                  GestureDetector(
                    onTap: () {
                      // Navigate to the About page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProdcutScreen()),
                      );
                    },
                    child: Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white, // Use a clickable color
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // Navigate to the About page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllProduct()),
                      );
                    },
                    child: Text(
                      'Shop',
                      style: TextStyle(
                        color: Colors.white, // Use a clickable color
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // Navigate to the About page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutUsPage()),
                      );
                    },
                    child: Text(
                      'About Us',
                      style: TextStyle(
                        color: Colors.white, // Use a clickable color
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // Navigate to the About page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContactPage()),
                      );
                    },
                    child: Text(
                      'Contact',
                      style: TextStyle(
                        color: Colors.white, // Use a clickable color
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                        onPressed: () async{
                          const url = 'https://www.facebook.com/medkartpharmacy';
                          if(await canLaunch(url)) {
                            await launch(
                              url,
                              webOnlyWindowName: '_blank',
                            );
                          }else{
                              throw 'Could not lunch $url';
                          }
                        },
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.instagram, color: Colors.white), // Instagram icon
                          onPressed: () async {
                            const url = 'https://www.instagram.com/medkartpharmacy?igsh=MWFtMGp4cjZ3c3VpNg==';
                            if (await canLaunch(url)) {
                              await launch(
                                url,
                                webOnlyWindowName: '_blank', // Opens in a new tab
                              );
                            } else {
                              throw 'Could not launch $url';
                            }
                          }
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.twitter, color: Colors.white), // Twitter icon
                          onPressed: () async {
                            const url = 'https://x.com/medkart';
                            if (await canLaunch(url)) {
                              await launch(
                                url,
                                webOnlyWindowName: '_blank', // Opens in a new tab
                              );
                            } else {
                              throw 'Could not launch $url';
                            }
                          }
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
