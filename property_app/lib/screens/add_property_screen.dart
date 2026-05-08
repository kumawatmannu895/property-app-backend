import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();

  File? selectedImage;

  final String baseUrl = "http://192.168.94.135:3000";

  // 👉 TOKEN GET
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 👉 Image pick
  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // 👉 Upload image
  Future<String?> uploadImage() async {
    if (selectedImage == null) return null;

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload/image"),
    );

    request.files.add(
      await http.MultipartFile.fromPath("file", selectedImage!.path),
    );

    var res = await request.send();

    if (res.statusCode == 200) {
      var responseData = await res.stream.bytesToString();
      var jsonData = json.decode(responseData);
      return jsonData["url"];
    }

    return null;
  }

  // 👉 Add property (SECURE)
  Future<void> addProperty() async {
    try {
      final token = await getToken();

      if (titleController.text.isEmpty ||
          priceController.text.isEmpty ||
          locationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields required ❌")),
        );
        return;
      }

      // 🔥 upload image first
      String? imageUrl = await uploadImage();

      final res = await http.post(
        Uri.parse("$baseUrl/property/add"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // 🔥 IMPORTANT
        },
        body: json.encode({
          "title": titleController.text,
          "price": int.parse(priceController.text),
          "location": locationController.text,
          "images": imageUrl != null ? [imageUrl] : [],
        }),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Property Added ✅")),
        );
        Navigator.pop(context);
      } else if (res.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired ❌")),
        );
      } else {
        print("Error: ${res.body}");
      }
    } catch (e) {
      print("Add Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Property")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),

              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Pick Image"),
              ),

              const SizedBox(height: 10),

              // 👉 Image preview
              if (selectedImage != null)
                Image.file(selectedImage!, height: 150),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: addProperty,
                child: const Text("Add Property"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}