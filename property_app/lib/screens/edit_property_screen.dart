import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditPropertyScreen extends StatefulWidget {
  final Map property;

  const EditPropertyScreen({
    super.key,
    required this.property,
  });

  @override
  State<EditPropertyScreen> createState() =>
      _EditPropertyScreenState();
}

class _EditPropertyScreenState
    extends State<EditPropertyScreen> {
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController locationController;

  bool isLoading = false;

  // ✅ RENDER BACKEND URL
  final String baseUrl =
      "https://property-app-backend-2vcd.onrender.com";

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.property["title"],
    );

    priceController = TextEditingController(
      text: widget.property["price"].toString(),
    );

    locationController = TextEditingController(
      text: widget.property["location"],
    );
  }

  // 👉 TOKEN GET
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 👉 UPDATE PROPERTY
  Future<void> updateProperty() async {
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields required ❌"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await getToken();

      final res = await http.put(
        Uri.parse(
          "$baseUrl/property/update/${widget.property["_id"]}",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "title": titleController.text.trim(),
          "price":
              int.tryParse(priceController.text) ?? 0,
          "location":
              locationController.text.trim(),
        }),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Updated successfully ✅"),
          ),
        );

        Navigator.pop(context);
      } else if (res.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Session expired ❌"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Update failed ❌: ${res.body}",
            ),
          ),
        );
      }
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Property ✏️"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),

              TextField(
                controller: priceController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: "Price",
                ),
              ),

              TextField(
                controller:
                    locationController,
                decoration:
                    const InputDecoration(
                  labelText: "Location",
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : updateProperty,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}