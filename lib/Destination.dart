import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dham_info_screen.dart';
import 'main.dart'; // for navigation to login

class Destination extends StatefulWidget {
  @override
  State<Destination> createState() => _DestinationState();
}

class _DestinationState extends State<Destination> {
  String? username = '';
  String? email = '';
  bool isLoadingUser = true;

  bool showProfileDrawer = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showYatraPopup();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('username');
    final savedEmail = prefs.getString('email');

    setState(() {
      username = savedName ?? 'User';
      email = savedEmail ?? 'N/A';
      isLoadingUser = false;
    });
  }


  void _showYatraPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Tap on your Yatra Sthan',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Welcome to YatraSathi 🙏🏻')),
          (route) => false,
    );
  }

  void _openProfileDrawer() {
    setState(() {
      showProfileDrawer = true;
    });
  }

  void _closeProfileDrawer() {
    setState(() {
      showProfileDrawer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // makes appbar transparent
      appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white70,
                child: Text("👤", style: TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ),
      ],
    ),

      endDrawer: Drawer(
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(-4, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white70,
                      child: Text("👋", style: TextStyle(fontSize: 34)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isLoadingUser ? "Hello..." : "Hello, ${username ?? 'User'}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Divider(color: Colors.black54, thickness: 0.8, indent: 16, endIndent: 16),

              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: Colors.black87),
                      title: const Text(
                        "Profile",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _openProfileDrawer();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.black87),
                      title: const Text(
                        "About App",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("YatraSathi v1.0 – Travel Made Easy 🛕")),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: Colors.black87),
                      title: const Text(
                        "Help & Support",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Contact us at support@yatrasathi.in")),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.black45, thickness: 0.8, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  onPressed: _logoutUser,
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.85),
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),


      // Second Drawer (Profile details)
      endDrawerEnableOpenDragGesture: false,
      body: GestureDetector(
        onTap: () {
      if (showProfileDrawer) _closeProfileDrawer(); // tap outside closes sidebar
    },
    child: Stack(
    fit: StackFit.expand,
    children: [
    Image.asset("assets/images/background2.png", fit: BoxFit.cover),
    Container(color: Colors.black.withOpacity(0.3)),

    // === LOCATION MARKERS ===
    Positioned(
    top: 300,
    left: MediaQuery.of(context).size.width * 0.28,
    child: locationCircle(
    image: "assets/images/badrinath.jpg",
    name: "Badrinath",
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => DhamInfoScreen(dhamName: "Badrinath"),
    ),
    );
    },
    ),
    ),
    Positioned(
    top: MediaQuery.of(context).size.height * 0.49,
    left: MediaQuery.of(context).size.width * 0.10,
    child: locationCircle(
    image: "assets/images/dwaraka.jpg",
    name: "Dwarka",
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => DhamInfoScreen(dhamName: "Dwarka"),
    ),
    );
    },
    ),
    ),
    Positioned(
    top: MediaQuery.of(context).size.height * 0.53,
    right: MediaQuery.of(context).size.width * 0.37,
    child: locationCircle(
    image: "assets/images/puri.jpg",
    name: "Puri",
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => DhamInfoScreen(dhamName: "Puri"),
    ),
    );
    },
    ),
    ),
    Positioned(
    bottom: 175,
    left: MediaQuery.of(context).size.width * 0.30,
    child: locationCircle(
    image: "assets/images/rameshwaram.jpg",
    name: "Rameswaram",
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) =>
    DhamInfoScreen(dhamName: "Rameswaram"),
    ),
    );
    },
    ),
    ),

    // === PROFILE DRAWER (Slide from right) ===
      AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        right: showProfileDrawer ? 0 : -260,
        top: 0,
        bottom: 0,
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD299C2), Color(0xFFFEF9D7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(-4, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: _closeProfileDrawer,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white70,
                      child: Text("👤", style: TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      username ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email ?? 'N/A',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Divider(color: Colors.black45, thickness: 0.8),
              const SizedBox(height: 15),
              const Text(
                "Account Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text("Username: ${username ?? 'User'}",
                        style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email_outlined, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(email ?? 'N/A',
                        style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Divider(color: Colors.black45, thickness: 0.8),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _logoutUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                ),
              ),
            ],
          ),
        ),
      ),

    ],
    ),
    ),

    );
  }

  Widget locationCircle({
    required String image,
    required String name,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          ClipOval(
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: Image.asset(
                image,
                height: 45,
                width: 45,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 3, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }
}
