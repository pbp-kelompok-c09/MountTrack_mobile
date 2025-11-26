import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/news/screen/news_page.dart';
import 'package:mounttrack_mobile/community/screens/event_list.dart';
import 'package:mounttrack_mobile/userprofile/screens/myprofile.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'register.dart';
import '../../mountains/screens/all_mountains.dart';
import '../../booking/screens/booking_landing.dart';

class DebugHomePage extends StatefulWidget {
  const DebugHomePage({super.key});

  @override
  State<DebugHomePage> createState() => _DebugHomePageState();
}

class _DebugHomePageState extends State<DebugHomePage> {
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // ambil username dari respons login terakhir
    String? username;
    try {
      final data = request.jsonData;
      if (data['username'] != null) {
        username = data['username'].toString();
      }
    } catch (_) {
      username = null;
    }

    final bool isLoggedIn = request.loggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MountTrack Debug Home'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Debug Menu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // status login
              Text(
                isLoggedIn ? 'Status: Logged in' : 'Status: Not logged in',
                style: TextStyle(
                  fontSize: 16,
                  color: isLoggedIn ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),

              // username
              if (isLoggedIn && username != null)
                Text(
                  'Username: $username',
                  style: const TextStyle(fontSize: 16),
                ),

              const SizedBox(height: 32),

              // tombol Login
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),

              // tombol register
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 12),

              // tombol my profile
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfilePage(),
                    ),
                  );
                },
                child: const Text('My Profile'),
              ),
              const SizedBox(height: 12),

              // Mountains list
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllMountainsPage(),
                    ),
                  );
                },
                child: const Text('Mountains'),
              ),
              const SizedBox(height: 12),
              
              // Booking
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingLandingPage(),
                    ),
                  );
                },
                child: const Text('Booking'),
              ),
              const SizedBox(height: 12),

              // Tombol News
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewsPage()),
                  );
                },
                child: const Text('News'),
              ),
              const SizedBox(height: 12),

              // tombol logout
              ElevatedButton(
                onPressed: isLoggedIn
                    ? () async {
                        final response = await request.logout(
                          "http://localhost:8000/accounts/logoutapp/",
                        );

                        if (!mounted) return;

                        // paksa rebuild supaya status & username update
                        setState(() {});

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message'] ??
                                    'Logged out (no message)',
                              ),
                            ),
                          );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
