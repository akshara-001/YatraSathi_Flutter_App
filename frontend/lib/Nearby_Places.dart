import 'package:flutter/material.dart';

class DhamDetailsScreen extends StatelessWidget {
  final String dhamName;
  DhamDetailsScreen({super.key, required this.dhamName});

  // 🕉️ Dham info with history + top image
  final Map<String, Map<String, String>> dhamInfo = {
    "Badrinath": {
      "image":
      "https://kedarnathtemple.com/wp-content/uploads/2021/08/badrinath-temple-in-may.jpg",
      "history":
      "Badrinath, dedicated to Lord Vishnu, is one of the holiest pilgrimage sites in India. Located in Uttarakhand, it is believed that Lord Vishnu meditated here while Goddess Lakshmi took the form of a Badri tree to protect him from the cold. The temple was established by Adi Shankaracharya in the 9th century and is part of both the Char Dham and Chota Char Dham pilgrimages."
    },
    "Dwarka": {
      "image":
      "https://www.ourvadodara.com/wp-content/uploads/2020/07/dwarka-dwarkadeesh-temple-148826502858-orijgp.jpg",
      "history":
      "Dwarka, located in Gujarat, is one of the ancient kingdoms of Lord Krishna. It is said that Krishna ruled here after leaving Mathura. The Dwarkadhish Temple, dedicated to Krishna, stands on the banks of the Gomti River and is one of the four major Char Dham pilgrimage sites."
    },
    "Puri": {
      "image":
      "https://www.mypuritour.com/wp-content/uploads/2022/08/puri-tour-2022.jpeg",
      "history":
      "Puri, in Odisha, is home to the world-famous Jagannath Temple. The temple is dedicated to Lord Jagannath (a form of Krishna) and is known for the grand Rath Yatra festival. The town’s spiritual history is deeply tied to Vaishnavism and has been a major center of pilgrimage for centuries."
    },
    "Rameswaram": {
      "image":
      "https://www.tripadventurer.in/wp-content/uploads/2023/11/rameshwaram-cover-image-1024x1024.jpg",
      "history":
      "Rameswaram, located in Tamil Nadu, is associated with Lord Rama’s journey to Lanka. According to the Ramayana, Lord Rama built a bridge (Ram Setu) from here to reach Lanka. The Ramanathaswamy Temple is one of the twelve Jyotirlingas of Lord Shiva, making it sacred for both Vaishnavites and Shaivites."
    },
  };

  // 🗺️ Nearby attractions for each Dham
  final Map<String, List<Map<String, String>>> nearbyPlaces = {
    "Badrinath": [
      {
        "name": "Mana Village",
        "distance": "3 km",
        "image":
        "https://devilonwheels.com/wp-content/uploads/2018/07/DSC_6964.jpg"
      },
      {
        "name": "Vasudhara Falls",
        "distance": "9 km",
        "image":
        "https://www.manchalamushafir.com/vasudhara-falls/images/vasudhara-waterfall.webp"
      },
      {
        "name": "Tapt Kund",
        "distance": "0.5 km",
        "image":
        "http://rishikeshdaytour.com/blog/wp-content/uploads/2023/01/Tapt-Kund.jpg"
      },
    ],
    "Dwarka": [
      {
        "name": "Bet Dwarka",
        "distance": "30 km",
        "image": "https://www.go2india.in/gujarat/images/dwarka-temple.JPG"
      },
      {
        "name": "Nageshwar Jyotirlinga",
        "distance": "17 km",
        "image":
        "https://www.trawell.in/admin/images/upload/900551700Dwarka_Nageshwar_Temple_main.jpg"
      },
      {
        "name": "Rukmini Devi Temple",
        "distance": "2 km",
        "image":
        "https://thrillingtravel.in/wp-content/uploads/2021/05/Rukmini-carving-devi-mandir-dwarka.jpg"
      },
    ],
    "Puri": [
      {
        "name": "Chilika Lake",
        "distance": "50 km",
        "image":
        "https://www.itl.cat/pngfile/big/173-1733692_sunrise-chilika-lake-at-rambha-odisha-india-beautiful.jpg"
      },
      {
        "name": "Konark Sun Temple",
        "distance": "35 km",
        "image":
        "https://www.tripvaani.com/wp-content/uploads/2020/05/Konark-Sun-Temple-or-Black-Pagoda-The-Chariot-of-Sun.jpg"
      },
      {
        "name": "Gundicha Temple",
        "distance": "3 km",
        "image":
        "https://media.tripinvites.com/places/puri/gundicha-temple/gundicha-temple-in-puri-featured.jpg"
      },
    ],
    "Rameswaram": [
      {
        "name": "Dhanushkodi Beach",
        "distance": "18 km",
        "image":
        "https://travelsetu.com/apps/uploads/new_destinations_photos/destination/2023/12/21/39a896bc07d1825cf8318d0037ca4157_1000x1000.jpg"
      },
      {
        "name": "Pamban Bridge",
        "distance": "2 km",
        "image": "https://live.staticflickr.com/725/21194296501_e16b90d486_b.jpg"
      },
      {
        "name": "Agni Theertham",
        "distance": "0.5 km",
        "image":
        "https://www.sharpholidays.in/blog/wp-content/uploads/2025/03/agni-theertham.jpg"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final dhamData = dhamInfo[dhamName]!;
    final places = nearbyPlaces[dhamName]!;

    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background image (plain, no overlay)
          Image.network(
            "https://wallpaperbat.com/img/391167-historical-desktop-background-19th.jpg",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // ✨ Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Dham Image
                Image.network(
                  dhamData["image"]!,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                // History Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dhamName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Historical Background",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dhamData["history"]!,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),

                // Nearby Attractions
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Nearby Attractions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return Container(
                        width: 170,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 3))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              child: Image.network(
                                place["image"]!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                place["name"]!,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.place,
                                      size: 16, color: Colors.deepOrange),
                                  const SizedBox(width: 4),
                                  Text(
                                    place["distance"]!,
                                    style: const TextStyle(
                                        color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
