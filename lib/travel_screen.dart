import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/travel_service.dart';

class TravelScreen extends StatefulWidget {
  final String dhamName;

  const TravelScreen({super.key, required this.dhamName});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> with SingleTickerProviderStateMixin {
  final TravelService _travelService = TravelService();

  String? _from, _to, _nearestAirport;
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _flights = [], _trains = [], _buses = [];
  bool _loading = false;
  late TabController _tabController;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCurrentCity();
    _setDestinationFromDham();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // 🗺️ Auto-select nearest airport for flights based on Dham
  void _setDestinationFromDham() {
    switch (widget.dhamName.toLowerCase()) {
      case 'badrinath':
        _nearestAirport = 'DED'; // Dehradun
        break;
      case 'dwarka':
        _nearestAirport = 'JGA'; // Jamnagar
        break;
      case 'puri':
        _nearestAirport = 'BBI'; // Bhubaneswar
        break;
      case 'rameswaram':
        _nearestAirport = 'IXM'; // Madurai
        break;
      default:
        _nearestAirport = 'DEL'; // Default Delhi
    }

    _to = widget.dhamName;
    _toController.text = "${widget.dhamName} ($_nearestAirport)";
  }

  Future<void> _getCurrentCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;

      setState(() {
        _from = "DEL";
        _fromController.text = "Delhi (DEL)";
      });
    } catch (e) {
      print("Location error: $e");
    }
  }

  Future<void> _search() async {
    if (_from == null || _to == null) return;
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final date = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final flights = await _travelService.getFlights(_from!, _nearestAirport!, date);
      final trains = await _travelService.getTrains(_from!, _to!, date);
      final buses = await _travelService.getBuses(_from!, _to!, date);

      if (!mounted) return;

      setState(() {
        _flights = flights;
        _trains = trains;
        _buses = buses;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: _selectedDate,
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  // ✈️ Flights → MakeMyTrip
  Future<void> bookFlight(String origin, String destination, String date) async {
    try {
      final parts = date.split('-');
      final formattedDate = "${parts[2]}/${parts[1]}/${parts[0]}";
      final url =
          'https://www.makemytrip.com/flight/search?itinerary=$origin-$destination-$formattedDate&tripType=O&paxType=A-1_C-0_I-0&intl=false&cabinClass=E&lang=eng';
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Flight booking error: $e");
    }
  }

  // 🚆 Trains → IRCTC
  Future<void> bookTrain(String from, String to) async {
    try {
      final url =
          'https://www.irctc.co.in/nget/train-search'; // IRCTC search page
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Train booking error: $e");
    }
  }

  // 🚌 Buses → RedBus (Delhi to Dham Example Mapping)
  Future<void> bookBus(String fromCityName, String toCityName) async {
    try {
      final formattedDate = DateFormat('dd-MMM-yyyy').format(_selectedDate);

      // Example city IDs (you can adjust based on actual routes)
      final cityMap = {
        'Delhi': '67062',
        'Badrinath': '318656',
        'Dwarka': '66042',
        'Puri': '73787',
        'Rameswaram': '67396',
      };

      final fromCityId = cityMap[fromCityName] ?? '67062';
      final toCityId = cityMap[toCityName] ?? '318656';

      final url =
          'https://www.redbus.in/';

      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Bus booking error: $e");
    }
  }

  List<Map<String, String>> cityList = [
    {'name': 'Delhi', 'code': 'DEL'},
    {'name': 'Mumbai', 'code': 'BOM'},
    {'name': 'Bengaluru', 'code': 'BLR'},
    {'name': 'Chennai', 'code': 'MAA'},
    {'name': 'Kolkata', 'code': 'CCU'},
    {'name': 'Hyderabad', 'code': 'HYD'},
    {'name': 'Goa', 'code': 'GOI'},
  ];

  Widget _buildList(List<dynamic> items, String type) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) return const Center(child: Text("No results found"));

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final name = item['airline'] ?? item['name'] ?? item['operator'] ?? 'N/A';
        final price = item['price']?.toString() ?? '-';
        final dep = item['departure'] ?? '';
        final arr = item['arrival'] ?? '';
        final busNo = item['busNo'] ?? ''; // 🚌 added this line

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: ListTile(
            title: Text(
              type == 'buses' && busNo.isNotEmpty
                  ? '$name ($busNo)' // show operator + bus number
                  : name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '$dep → $arr\n₹$price',
              style: const TextStyle(height: 1.5),
            ),
            trailing: ElevatedButton(
              onPressed: () async {
                final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
                if (type == 'flights') {
                  bookFlight(_from!, _nearestAirport!, date);
                } else if (type == 'trains') {
                  await bookTrain(_from!, _to!);
                } else if (type == 'buses') {
                  await bookBus('Delhi', widget.dhamName);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                side: const BorderSide(color: Colors.deepPurple, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Book Now",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( appBar: AppBar( title: Text( "Travel to ${widget.dhamName}",
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), ),
      centerTitle: true, elevation: 4,
      flexibleSpace: Container(
        decoration: const BoxDecoration( gradient: LinearGradient( colors: [Color(0xFF30CFD0), Color(0xFF330867)],
          begin: Alignment.topLeft, end: Alignment.bottomRight, ), ), ),
      bottom: TabBar( controller: _tabController,
        tabs: const [ Tab(child: Text("Flights ✈️", style: TextStyle(color: Colors.white))),
          Tab(child: Text("Trains 🚆", style: TextStyle(color: Colors.white))),
          Tab(child: Text("Buses 🚌", style: TextStyle(color: Colors.white))), ], ), ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TypeAheadField<Map<String, String>>(
                    suggestionsCallback: (pattern) => cityList
                        .where((city) =>
                        city['name']!.toLowerCase().contains(pattern.toLowerCase()))
                        .toList(),
                    builder: (context, controller, focusNode) => TextField(
                      controller: _fromController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: "From City"),
                    ),
                    itemBuilder: (context, city) =>
                        ListTile(title: Text("${city['name']} (${city['code']})")),
                    onSelected: (city) {
                      _fromController.text = "${city['name']} (${city['code']})";
                      _from = city['code'];
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _toController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "To City (Auto-selected)"),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text("Change Date"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade300),
                  child: const Text("Search", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_flights, 'flights'),
                _buildList(_trains, 'trains'),
                _buildList(_buses, 'buses'),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
