import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadImageScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  UploadImageScreen({required this.product});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Pick images from the gallery
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images.clear();
        _images.addAll(pickedFiles);
      });
    }
  }

  // Upload images to the backend
  Future<void> _uploadImages() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one image.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a multipart request
      var uri = Uri.parse('http://localhost:5000/upload');
      var request = http.MultipartRequest('POST', uri);

      // Add ws_code to the request
      request.fields['ws_code'] = widget.product['ws_code'].toString();

      // Add images to the request
      for (var image in _images) {
        var bytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'images', // Must match the key in your backend
            bytes,
            filename: image.name,
          ),
        );
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Images uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload images.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Upload Images for ${widget.product['name']}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image picker section
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey[200],
                child: Text(
                  _images.isEmpty
                      ? 'Tap here to select images'
                      : '${_images.length} image(s) selected',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Image previews
            // Image previews
            _images.isNotEmpty
                ? Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<Uint8List>(
                    future: _images[index].readAsBytes(), // Read the image bytes asynchronously
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.memory(
                            snapshot.data!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            )
                : SizedBox.shrink(),


            SizedBox(height: 20),

            // WS Code display
            Text(
              "ws_code: ${widget.product['ws_code']}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Upload button
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImages,
              child: _isUploading
                  ? CircularProgressIndicator(
                color: Colors.white,
              )
                  : Text("Upload Images"),
            ),
          ],
        ),
      ),
    );
  }
}
