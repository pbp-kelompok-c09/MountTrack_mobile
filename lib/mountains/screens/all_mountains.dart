import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../booking/screens/booking_form_page.dart';
import '../../userprofile/screens/login.dart';
import 'mountain_details.dart';

class AllMountainsPage extends StatelessWidget {
  const AllMountainsPage({super.key});

  // Sample data. Replace with real API calls via CookieRequest in future.
  List<Map<String, String>> get sampleMountains => const [
        {
          'id': '1',
          'name': 'Mount Everest',
          'height': '8,848',
          'summary': 'Highest mountain on Earth.',
          'rating': '4.8',
          'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        },
        {
          'id': '2',
          'name': 'K2',
          'height': '8,611',
          'summary': 'Second highest peak, very challenging.',
          'rating': '4.9',
          'image': 'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=800',
        },
        {
          'id': '3',
          'name': 'Kangchenjunga',
          'height': '8,586',
          'summary': 'Third highest peak.',
          'rating': '4.7',
          'image': 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?w=800',
        },
      ];

  @override
  Widget build(BuildContext context) {
    final items = sampleMountains;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'All Mountains',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32), // Green
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero Section with Image, Quote, and Search Bar
          Stack(
            children: [
              // Background Image
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Content Overlay
              Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Quote
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '"The mountains are calling\nand I must go"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    '- John Muir',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search mountains...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF2E7D32), // Green
                          ),
                          suffixIcon: const Icon(
                            Icons.tune,
                            color: Color(0xFF5D4037), // Brown
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
          
          // Mountain Cards Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((m) {
                return Column(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mountain Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              m['image'] ?? '',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.terrain,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Mountain Info
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Mountain Name
                                Text(
                                  m['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32), // Green
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Height
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.height,
                                      size: 18,
                                      color: Color(0xFF5D4037), // Brown
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${m['height']} MDPL',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Star Rating
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      m['rating'] ?? '0.0',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MountainDetailsPage(
                                                id: m['id']!,
                                                name: m['name']!,
                                                height: m['height']!,
                                                description: m['summary']!,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF5D4037), // Brown
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'View Details',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final request = context.read<CookieRequest>();
                                          if (!request.loggedIn) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const LoginPage(),
                                              ),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Silakan login untuk melakukan booking.')),
                                            );
                                            return;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BookingFormPage(
                                                mountainId: m['id']!,
                                                mountainName: m['name']!,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2E7D32), // Green
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'Book',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}