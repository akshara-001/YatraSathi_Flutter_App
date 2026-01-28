import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'services/geoapify_service.dart';
import 'services/pixabay_service.dart';

class HotelRestaurantScreen extends StatefulWidget {
  final String dhamName;
  final double lat;
  final double lon;

  const HotelRestaurantScreen({
    super.key,
    required this.dhamName,
    required this.lat,
    required this.lon,
  });

  @override
  State<HotelRestaurantScreen> createState() => _HotelRestaurantScreenState();
}

class _HotelRestaurantScreenState extends State<HotelRestaurantScreen>
    with SingleTickerProviderStateMixin {
  final GeoapifyService _geoService = GeoapifyService();
  final PixabayService _pixabay = PixabayService(); // ✅ new
  final Distance _distance = const Distance();

  List<Map<String, dynamic>> _hotels = [];
  List<Map<String, dynamic>> _restaurants = [];
  bool _loadingHotels = true;
  bool _loadingRestaurants = true;

  LatLng? _userLocation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initLocationAndData();
  }

  Future<void> _initLocationAndData() async {
    await _getUserLocation();
    await _loadData();
    setState(() {});
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enable location services.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions permanently denied.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _geoService.nearbySearch(lat: widget.lat, lon: widget.lon, type: 'hotel'),
        _geoService.nearbySearch(lat: widget.lat, lon: widget.lon, type: 'restaurant'),
      ]);

      List<Map<String, dynamic>> hotels = results[0];
      List<Map<String, dynamic>> restaurants = results[1];

      // 🔁 Fetch Pixabay images
      for (var place in hotels) {
        final name = place['name'] ?? 'hotel';
        place['image'] = await _pixabay.getImageForPlace('$name hotel');
      }
      for (var place in restaurants) {
        final name = place['name'] ?? 'restaurant';
        place['image'] = await _pixabay.getImageForPlace('$name restaurant');
      }

      setState(() {
        _hotels = hotels;
        _restaurants = restaurants;
        _loadingHotels = false;
        _loadingRestaurants = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _loadingHotels = false;
        _loadingRestaurants = false;
      });
    }
  }

  double? _getDistance(double? lat, double? lon) {
    if (_userLocation == null || lat == null || lon == null) return null;
    return _distance.as(LengthUnit.Kilometer, _userLocation!, LatLng(lat, lon));
  }

  void _showMap(double lat, double lon, String name) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Directions to $name'),
            backgroundColor: Colors.deepOrange,
          ),
          body: FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation ?? LatLng(widget.lat, widget.lon),
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.next_project',
              ),
              MarkerLayer(markers: [
                if (_userLocation != null)
                  Marker(
                    width: 60,
                    height: 60,
                    point: _userLocation!,
                    child: const Icon(Icons.person_pin_circle,
                        color: Colors.blue, size: 40),
                  ),
                Marker(
                  width: 60,
                  height: 60,
                  point: LatLng(lat, lon),
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    final name = place['name'] ?? 'Unknown';
    final address = place['formatted'] ?? '';
    final website = place['website'] ?? '';
    final lat = place['lat']?.toDouble();
    final lon = place['lon']?.toDouble();
    final imageUrl = place['image'];

    final distance = _getDistance(lat, lon);
    final distanceText =
    (distance != null) ? '${distance.toStringAsFixed(1)} km away' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => _fallbackIcon(),
                )
                    : _fallbackIcon(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis),
                    if (distanceText.isNotEmpty)
                      Text(distanceText,
                          style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w500,
                              fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(address,
                        style: const TextStyle(color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (lat != null && lon != null)
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.blue, size: 22),
                          onPressed: () => _showMap(lat, lon, name),
                        ),
                      if (website.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.link,
                              color: Colors.green, size: 22),
                          onPressed: () async {
                            final uri = Uri.parse(website);
                            await launchUrl(uri,
                                mode: LaunchMode.inAppWebView);
                          },
                        ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() => Container(
    width: 90,
    height: 90,
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.hotel, color: Colors.deepOrange, size: 40),
  );

  Widget _buildList(List<Map<String, dynamic>> data, bool loading) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (data.isEmpty) {
      return const Center(child: Text('No results found.'));
    } else {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          itemCount: data.length,
          itemBuilder: (context, i) => _buildPlaceCard(data[i]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.dhamName} • Nearby',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF6D365), // light sunny yellow
                Color(0xFFFDA085), // soft orange
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: const Icon(Icons.hotel), text: "Hotels (${_hotels.length})"),
            Tab(icon: const Icon(Icons.restaurant), text: "Restaurants (${_restaurants.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_hotels, _loadingHotels),
          _buildList(_restaurants, _loadingRestaurants),
        ],
      ),
    );
  }
}
