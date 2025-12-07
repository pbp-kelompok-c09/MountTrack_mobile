// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:mounttrack_mobile/widgets/app_navbar.dart';
// import 'package:mounttrack_mobile/widgets/bottom_navbar.dart';
// import 'package:mounttrack_mobile/mountains/screens/all_mountains.dart';
// import 'package:mounttrack_mobile/userprofile/screens/myprofile.dart';
// import 'package:mounttrack_mobile/userprofile/screens/login.dart';
// import 'package:mounttrack_mobile/booking/screens/booking_landing.dart';
// import 'package:mounttrack_mobile/news/screen/news_page.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;

//   late final List<Widget> _screens = [
//     const _HomeContent(),
//     const AllMountainsPage(),
//     const BookingLandingPage(),
//     const MyProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _currentIndex == 0
//           ? AppNavBar(title: 'MountTrack', showBack: false)
//           : null,
//       body: _screens[_currentIndex],
//       floatingActionButton: FloatingActionButton.small(
//         onPressed: () {
//           final request = context.read<CookieRequest>();
//           if (!request.loggedIn) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const LoginPage()),
//             );
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Silakan login untuk membuat booking.'),
//               ),
//             );
//             return;
//           }

//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const BookingLandingPage()),
//           );
//         },
//         tooltip: 'Tambah Booking',
//         backgroundColor: const Color(0xFF2E7D32),
//         child: const Icon(Icons.add),
//       ),
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }

// class _HomeContent extends StatelessWidget {
//   const _HomeContent();

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Welcome Banner
//           Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Selamat Datang!',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Jelajahi gunung-gunung menakjubkan dan rencanakan petualangan Anda',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white70,
//                     height: 1.4,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const AllMountainsPage(),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: const Color(0xFF2E7D32),
//                   ),
//                   child: const Text('Lihat Gunung-Gunung'),
//                 ),
//               ],
//             ),
//           ),
//           // Quick Actions
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Aksi Cepat',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildQuickActionCard(
//                       icon: Icons.calendar_today,
//                       label: 'Booking Baru',
//                       onTap: () {
//                         // go to mountains list so user can pick a mountain to book
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const AllMountainsPage(),
//                           ),
//                         );
//                       },
//                     ),
//                     _buildQuickActionCard(
//                       icon: Icons.history,
//                       label: 'Riwayat',
//                       onTap: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Navigasi ke riwayat')),
//                         );
//                       },
//                     ),
//                     _buildQuickActionCard(
//                       icon: Icons.group,
//                       label: 'Komunitas',
//                       onTap: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Navigasi ke komunitas'),
//                           ),
//                         );
//                       },
//                     ),
//                     _buildQuickActionCard(
//                       icon: Icons.newspaper,
//                       label: 'Berita',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const NewsPage(),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Featured Mountains
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Gunung Populer',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildMountainCard(
//                   name: 'Mount Everest',
//                   height: '8,848 m',
//                   difficulty: 'Advanced',
//                   imageUrl:
//                       'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
//                 ),
//                 const SizedBox(height: 12),
//                 _buildMountainCard(
//                   name: 'K2',
//                   height: '8,611 m',
//                   difficulty: 'Advanced',
//                   imageUrl:
//                       'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=400',
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionCard({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 64,
//             height: 64,
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8F5E9),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(icon, color: const Color(0xFF2E7D32), size: 32),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMountainCard({
//     required String name,
//     required String height,
//     required String difficulty,
//     required String imageUrl,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           color: Colors.white,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   Image.network(
//                     imageUrl,
//                     height: 160,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: difficulty == 'Advanced'
//                             ? Colors.red[400]
//                             : Colors.orange[400],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         difficulty,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Ketinggian: $height',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
