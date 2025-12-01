// import 'package:flutter/material.dart';
// import 'package:mounttrack_mobile/widgets/bottom_navbar.dart';
// import 'package:mounttrack_mobile/mountains/screens/all_mountains.dart';
// import 'package:mounttrack_mobile/userprofile/screens/login.dart';

// class LandingPage extends StatefulWidget {
//   const LandingPage({super.key});

//   @override
//   State<LandingPage> createState() => _LandingPageState();
// }

// class _LandingPageState extends State<LandingPage> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Hero Section
//             Container(
//               height: 400,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     const Color(0xFF2E7D32),
//                     const Color(0xFF1B5E20),
//                   ],
//                 ),
//               ),
//               child: Stack(
//                 children: [
//                   // Background Image/Pattern
//                   Positioned.fill(
//                     child: Opacity(
//                       opacity: 0.1,
//                       child: Image.network(
//                         'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   // Content
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 40),
//                       // Logo/Title
//                       const Text(
//                         'MountTrack',
//                         style: TextStyle(
//                           fontSize: 48,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // Tagline
//                       const Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 24),
//                         child: Text(
//                           'Jelajahi, Rencanakan, Daki Dengan Aman',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.white70,
//                             height: 1.4,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 32),
//                       // CTA Button
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const AllMountainsPage(),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: const Color(0xFF2E7D32),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 48,
//                             vertical: 16,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         child: const Text(
//                           'Mulai Sekarang',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Features Section
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Fitur Utama',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   // Feature Cards
//                   _buildFeatureCard(
//                     icon: Icons.map_outlined,
//                     title: 'Informasi Gunung',
//                     description:
//                         'Jelajahi daftar gunung aktif dengan ketinggian dan kondisi jalur terkini',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildFeatureCard(
//                     icon: Icons.calendar_today_outlined,
//                     title: 'Booking Pendakian',
//                     description:
//                         'Reservasi jalur resmi pendakian gunung dengan mudah melalui aplikasi',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildFeatureCard(
//                     icon: Icons.people_outline,
//                     title: 'Komunitas',
//                     description:
//                         'Berinteraksi dengan pecinta alam lainnya dan kelola rencana pendakian bersama',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildFeatureCard(
//                     icon: Icons.newspaper_outlined,
//                     title: 'Berita & Tren',
//                     description:
//                         'Dapatkan informasi terbaru seputar dunia pecinta alam dan pendakian',
//                   ),
//                 ],
//               ),
//             ),
//             // About Section
//             Container(
//               color: const Color(0xFFF5F5F5),
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Tentang MountTrack',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'MountTrack adalah platform informasi pendakian yang komprehensif untuk semua '
//                     'pecinta alam di Indonesia. Kami menyediakan informasi lengkap tentang gunung-gunung '
//                     'aktif, kondisi jalur terkini, berita terbaru, dan layanan booking pendakian yang mudah.\n\n'
//                     '"Keselamatan dan kenyamanan petualangan Anda adalah prioritas kami."',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF424242),
//                       height: 1.6,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Stats Section
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildStatCard(
//                     number: '50+',
//                     label: 'Gunung Terdaftar',
//                   ),
//                   _buildStatCard(
//                     number: '10K+',
//                     label: 'Pengguna Aktif',
//                   ),
//                   _buildStatCard(
//                     number: '1000+',
//                     label: 'Booking Berhasil',
//                   ),
//                 ],
//               ),
//             ),
//             // CTA Section
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const Text(
//                     'Siap untuk Petualangan?',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Login atau buat akun baru untuk mulai merencanakan perjalanan pendakian Anda',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.grey,
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Navigate to login
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const LoginPage(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2E7D32),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Masuk / Daftar',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Footer
//             Container(
//               color: Colors.grey[200],
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'MountTrack © 2025',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Platform Informasi Pendakian Indonesia',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
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

//   Widget _buildFeatureCard({
//     required IconData icon,
//     required String title,
//     required String description,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8F5E9),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFF2E7D32),
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   description,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required String number,
//     required String label,
//   }) {
//     return Column(
//       children: [
//         Text(
//           number,
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2E7D32),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }
// }
