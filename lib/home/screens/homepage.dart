import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/booking/screens/booking_form_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../widgets/base_scaffold.dart';
import '../../mountains/screens/all_mountains.dart';
import '../../booking/screens/booking_landing.dart';
import '../../news/screen/news_page.dart';
import '../../community/screens/event_list.dart';
import '../../userprofile/screens/login.dart';
import '../../userprofile/screens/myprofile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const cafeNoir = Color(0xFF4C3D19);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return BaseScaffold(
      title: 'MountTrack',
      backgroundColor: bone,
      appBarBackgroundColor: kombuGreen,
      appBarElevation: 0,
      appBarIconTheme: const IconThemeData(color: bone),
      titleTextStyle: const TextStyle(
        color: bone,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: true,
      showBack: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: bone),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyProfilePage(),
              ),
            );
          },
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kombuGreen, cafeNoir],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: kombuGreen);
                        },
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          request.loggedIn
                              ? 'Selamat Datang Kembali, Penjelajah!'
                              : 'Selamat Datang di MountTrack',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: bone,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Jelajahi, Rencanakan, dan Daki Gunung dengan Aman',
                          style: TextStyle(
                            fontSize: 16,
                            color: bone,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!request.loggedIn)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Masuk / Daftar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bone,
                              foregroundColor: kombuGreen,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Stats Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Jelajahi Fitur Kami',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kombuGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Temukan gunung, pesan petualanganmu, dan terhubung dengan komunitas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Module Cards Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildModuleCard(
                        context: context,
                        title: 'Gunung',
                        description: 'Jelajahi puncak & jalur',
                        icon: Icons.terrain,
                        color: kombuGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllMountainsPage(),
                            ),
                          );
                        },
                      ),
                      _buildModuleCard(
                        context: context,
                        title: 'Pemesanan',
                        description: 'Rencanakan pendakian',
                        icon: Icons.calendar_month,
                        color: cafeNoir,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingFormPage(),
                            ),
                          );
                        },
                      ),
                      _buildModuleCard(
                        context: context,
                        title: 'Berita',
                        description: 'Kabar terbaru',
                        icon: Icons.newspaper,
                        color: mossGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewsPage(),
                            ),
                          );
                        },
                      ),
                      _buildModuleCard(
                        context: context,
                        title: 'Komunitas',
                        description: 'Event & forum',
                        icon: Icons.people,
                        color: const Color(0xFF6B5D4F),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CommunityEventListPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Features Highlight Section
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tan),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mengapa Memilih MountTrack?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kombuGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.verified_user,
                    title: 'Aman & Terpercaya',
                    description: 'Informasi gunung terverifikasi dan sistem pemesanan terpercaya',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.schedule,
                    title: 'Pembaruan Real-time',
                    description: 'Dapatkan berita terbaru dan kondisi gunung',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.group,
                    title: 'Berbasis Komunitas',
                    description: 'Terhubung dengan sesama pendaki gunung',
                  ),
                ],
              ),
            ),

            // Call to Action
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kombuGreen.withOpacity(0.8), cafeNoir.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Siap untuk Petualangan Selanjutnya?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: bone,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mulai jelajahi gunung dan rencanakan pendakianmu hari ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: bone,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllMountainsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Jelajahi Gunung'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bone,
                      foregroundColor: kombuGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tan.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: bone),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kombuGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kombuGreen, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
