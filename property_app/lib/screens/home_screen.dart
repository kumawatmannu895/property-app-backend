import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'add_property_screen.dart';
import 'edit_property_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List properties = [];

  // ✅ RENDER BASE URL
  final String baseUrl =
      "https://property-app-backend-2vcd.onrender.com";

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  // 👉 COMMON FUNCTION (TOKEN)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 👉 Fetch Properties (SECURE)
  Future<void> fetchProperties() async {
    try {
      final token = await getToken();

      final res = await http.get(
        Uri.parse("$baseUrl/property"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        setState(() {
          properties = json.decode(res.body);
        });
      } else if (res.statusCode == 401) {
        logout(); // 🔥 token expired
      } else {
        print("Error: ${res.statusCode}");
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
  }

  // 👉 DELETE Property (SECURE)
  Future<void> deleteProperty(String id) async {
    try {
      final token = await getToken();

      final res = await http.delete(
        Uri.parse("$baseUrl/property/delete/$id"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        fetchProperties();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Deleted successfully 🗑️"),
          ),
        );
      } else if (res.statusCode == 401) {
        logout();
      } else {
        print("Delete failed");
      }
    } catch (e) {
      print("Delete Error: $e");
    }
  }

  // 👉 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Properties 🏠"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: properties.isEmpty
          ? const Center(
              child: Text("No Data Found ❌"),
            )
          : ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final item = properties[index];

                String imageUrl = "";

                if (item["images"] != null &&
                    item["images"].isNotEmpty) {
                  imageUrl = item["images"][0]
                      .toString()
                      .replaceAll(
                        "http://localhost:3000",
                        "https://property-app-backend-2vcd.onrender.com",
                      );
                }

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.home),

                    title: Text(item["title"] ?? ""),

                    subtitle: Text(
                      "₹ ${item["price"]} - ${item["location"]}",
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✏️ EDIT
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditPropertyScreen(
                                  property: item,
                                ),
                              ),
                            );

                            fetchProperties();
                          },
                        ),

                        // ❌ DELETE
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            deleteProperty(item["_id"]);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AddPropertyScreen(),
            ),
          );

          fetchProperties();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}