import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DhamGalleryScreen extends StatefulWidget {
  final String dhamName;
  const DhamGalleryScreen({super.key, required this.dhamName});

  @override
  State<DhamGalleryScreen> createState() => _DhamGalleryScreenState();
}

class _DhamGalleryScreenState extends State<DhamGalleryScreen> {
  final String baseUrl = "http://10.122.13.214:5000/api/gallery";

  String? currentUsername;
  List photos = [];
  final picker = ImagePicker();
  File? _image;
  TextEditingController captionController = TextEditingController();
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadUsername();
    fetchGallery();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadUsername(); //  refresh username each time the screen becomes active
  }


  //  Fetch logged-in username from SharedPreferences
  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? 'Guest';
    });
  }

  Future<void> fetchGallery() async {
    final res = await http.get(Uri.parse('$baseUrl/${widget.dhamName}'));
    if (res.statusCode == 200) {
      setState(() {
        photos = jsonDecode(res.body);
      });
    }
  }

  Future<void> uploadPhoto() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    if (currentUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    setState(() => isUploading = true);

    final request = http.MultipartRequest("POST", Uri.parse('$baseUrl/upload'));
    request.fields['username'] = currentUsername!;
    request.fields['caption'] = captionController.text;
    request.fields['dham'] = widget.dhamName;
    request.files.add(await http.MultipartFile.fromPath("image", _image!.path));

    try {
      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo uploaded successfully!")),
        );
        setState(() {
          _image = null;
          captionController.clear();
        });
        await fetchGallery();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Widget buildGalleryCard(Map photo) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(photo['imageUrl'], fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    photo['likes'].contains(currentUsername)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    await http.put(
                      Uri.parse('$baseUrl/${photo['_id']}/like'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'username': currentUsername}),
                    );
                    fetchGallery();
                  },
                ),
                Text("${photo['likes'].length} likes",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text("${photo['username']}: ${photo['caption']}"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.dhamName} Gallery"),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFdad4ec), Color(0xFFf3e7e9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFdad4ec), Color(0xFFf3e7e9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: fetchGallery,
          child: ListView(
            children: [
              if (_image != null)
                Column(
                  children: [
                    Image.file(_image!, height: 180, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: captionController,
                              decoration: const InputDecoration(
                                labelText: "Add a caption...",
                              ),
                            ),
                          ),
                          IconButton(
                            icon: isUploading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            )
                                : const Icon(Icons.upload, color: Colors.blue),
                            onPressed: isUploading ? null : uploadPhoto,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text("Upload Photo"),
                  ),
                ),
              ...photos.map((p) => buildGalleryCard(p)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
