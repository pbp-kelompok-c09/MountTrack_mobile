import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../widgets/app_navbar.dart';
import '../../mountains/screens/all_mountains.dart';
import '../../userprofile/screens/login.dart';

class BookingLandingPage extends StatelessWidget {
  const BookingLandingPage({super.key});


  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  static const sacramento = Color(0xFF102114);
  static const pine = Color(0xFF294122);
  static const salmon = Color(0xFFFFBBA6);
  static const tangerine = Color(0xFFEB3D00);
  static const chiffon = Color(0xFFFFEED2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: 'Booking', showBack: true),
      backgroundColor: bone,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: chiffon,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cafeNoir.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Pendakian',
                      style: TextStyle(
                        color: kombuGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rencanakan pendakianmu dengan aman. Pilih jumlah peserta, tingkat pengalaman, dan kami akan merekomendasikan kebutuhan porter jika diperlukan.',
                      style: TextStyle(
                        color: pine.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
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
                                  const SnackBar(content: Text('Silakan login untuk memulai booking.')),
                                );
                                return;
                              }

                              // go to mountains list for selection
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllMountainsPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kombuGreen,
                              foregroundColor: bone,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Mulai Booking'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllMountainsPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: mossGreen),
                            foregroundColor: mossGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Jelajahi Gunung'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Why book with us
              Text(
                'Kenapa Booking di sini?',
                style: TextStyle(
                  color: cafeNoir,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _featureTile(
                icon: Icons.verified_user,
                title: 'Keamanan & Verifikasi',
                subtitle: 'Data porter dan pemandu diverifikasi untuk keamanan perjalanan.',
                color: mossGreen,
              ),
              _featureTile(
                icon: Icons.group,
                title: 'Pilihan Paket',
                subtitle: 'Kelola jumlah peserta dan level untuk rekomendasi porter otomatis.',
                color: kombuGreen,
              ),
              _featureTile(
                icon: Icons.support_agent,
                title: 'Dukungan 24/7',
                subtitle: 'Bantuan jika diperlukan sebelum, saat, dan sesudah pendakian.',
                color: pine,
              ),

              const SizedBox(height: 36),
              Center(
                child: Text(
                  'Siap untuk petualanganmu?',
                  style: TextStyle(
                    color: sacramento,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureTile({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bone,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: cafeNoir, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: cafeNoir.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
