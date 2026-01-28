import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:next_project/Nearby_Places.dart';
import 'dart:convert';
import 'hotel_and_restaurants_screen.dart';
import 'travel_screen.dart';
import 'Gallery_screen.dart';


class DhamInfoScreen extends StatefulWidget {
  final String dhamName;

  const DhamInfoScreen({super.key, required this.dhamName});

  @override
  State<DhamInfoScreen> createState() => _DhamInfoScreenState();
}

class _DhamInfoScreenState extends State<DhamInfoScreen> {
  String temperature = '';
  String weatherCondition = '';
  LinearGradient weatherGradient = const LinearGradient(
    colors: [Colors.orangeAccent, Colors.deepOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  bool isLoading = true;
  String backgroundImage = '';

  @override
  void initState() {
    super.initState();
    setBackgroundImage();
    fetchWeather();
  }

  void setBackgroundImage() {
    switch (widget.dhamName.toLowerCase()) {
      case 'badrinath':
        backgroundImage = 'assets/images/badrinath_bg.jpg';
        break;
      case 'dwarka':
        backgroundImage = 'assets/images/dwaraka_bg.jpg';
        break;
      case 'puri':
        backgroundImage = 'assets/images/Puri_bg.jpg';
        break;
      case 'rameswaram':
        backgroundImage = 'assets/images/Rameswaram_bg.jpg';
        break;
      default:
        backgroundImage = 'assets/images/default.jpg';
    }
  }

  Future<void> fetchWeather() async {
    const apiKey = 'b0379b22ce897b455d61fdc9ae96966d';
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(widget.dhamName)}&appid=$apiKey&units=metric',
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final condition = data['weather'][0]['main'] ?? '';

        setState(() {
          temperature = '${data['main']['temp'].round()}°C';
          weatherCondition = condition;
          isLoading = false;

          switch (condition.toLowerCase()) {
            case 'clouds':
              weatherGradient = const LinearGradient(
                colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              break;
            case 'rain':
            case 'drizzle':
            case 'thunderstorm':
              weatherGradient = const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              break;
            case 'snow':
              weatherGradient = const LinearGradient(
                colors: [Colors.white, Colors.blueGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              break;
            case 'mist':
            case 'fog':
              weatherGradient = const LinearGradient(
                colors: [Colors.grey, Colors.white70],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              break;
            default:
              weatherGradient = const LinearGradient(
                colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
          }
        });
      } else {
        setState(() {
          temperature = 'N/A';
          weatherCondition = 'Not Found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        temperature = 'Error';
        weatherCondition = 'Check connection';
        isLoading = false;
      });
    }
  }

  String getWeatherImage(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
        return 'assets/images/Cloudy.png';
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return 'assets/images/rainy.png';
      case 'snow':
        return 'assets/images/snow.png';
      case 'mist':
      case 'fog':
        return 'assets/images/mist.png';
      default:
        return 'assets/images/Sunny.png';
    }
  }

  Widget buildInfoCard(
      String title, String subtitle, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0), // Light orange
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.8),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.white.withOpacity(0.1)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
                : Column(
              children: [


                // 🌦 Weather Box (Image + Info)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: weatherGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: weatherGradient.colors.last.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.dhamName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              weatherCondition,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              temperature,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Image.asset(
                          getWeatherImage(weatherCondition),
                          height: 110,
                          width: 110,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🏨 Info Cards
                Expanded(
                  child: ListView(
                    children: [
                      buildInfoCard(
                        "Hotels & Restaurants",
                        "Taste the Culture and Explore Stays",
                        'assets/images/Hotels.png',
                            () {
                              double lat = 0.0;
                              double lon = 0.0;

                              switch (widget.dhamName.toLowerCase()) {
                                case 'badrinath':
                                  lat = 30.7433;
                                  lon = 79.4930;
                                  break;
                                case 'dwarka':
                                  lat = 22.2442;
                                  lon = 68.9685;
                                  break;
                                case 'puri':
                                  lat = 19.8135;
                                  lon = 85.8312;
                                  break;
                                case 'rameswaram':
                                  lat = 9.2881;
                                  lon = 79.3129;
                                  break;
                                default:
                                  lat = 28.6139; // fallback: Delhi
                                  lon = 77.2090;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HotelRestaurantScreen(
                                    dhamName: widget.dhamName,
                                    lat: lat,
                                    lon: lon,
                                  ),
                                ),
                              );
                            },
                      ),
                      buildInfoCard(
                        "Travel / Transport",
                        "Know Your Schedule",
                        'assets/images/travel.png',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TravelScreen(dhamName: widget.dhamName),
                                ),
                              );
                            },
                      ),
                      buildInfoCard(
                        "Gallery",
                        "Explore Others’ Experiences and Views",
                        'assets/images/gallery.png',
                            () {Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DhamGalleryScreen(
                                    dhamName: widget.dhamName,
                                ),
                              ),
                            );},
                      ),
                      buildInfoCard(
                        "History & Nearby Places",
                        "Some More Places? Yes!",
                        'assets/images/Suggestions.png',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DhamDetailsScreen(
                                    dhamName: widget.dhamName,
                                  ),
                                ),
                              );
                            },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
