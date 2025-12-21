import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/widgets/base_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../config.dart';
import '../../booking/screens/booking_form_page.dart';
import '../../userprofile/screens/login.dart';
import '../models/mountain.dart';

class MountainDetailsPage extends StatefulWidget {
  final int mountainId;

  const MountainDetailsPage({
    super.key,
    required this.mountainId,
  });

  @override
  State<MountainDetailsPage> createState() => _MountainDetailsPageState();
}

class _MountainDetailsPageState extends State<MountainDetailsPage> {
  Mountain? _mountain;
  bool _isLoading = true;

  static const cafeNoir = Color(0xFF4C3D19);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);

  @override
  void initState() {
    super.initState();
    _fetchMountainDetails();
  }

  Future<void> _fetchMountainDetails() async {
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    try {
      print('Fetching mountain detail for ID: ${widget.mountainId}');
      final response = await request.get(
        '${AppConfig.baseUrl}/mountains/api/mountains/${widget.mountainId}/',
      );

      print('Detail response: $response');
      
      if (response != null) {
        setState(() {
          _mountain = Mountain.fromJson(response);
          _isLoading = false;
        });
      } else {
        print('Response is null');
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mountain not found')),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error fetching mountain details: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading mountain details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: _mountain?.name ?? 'Mountain Details',
      backgroundColor: bone,
      appBarBackgroundColor: kombuGreen,
      appBarIconTheme: const IconThemeData(color: bone),
      titleTextStyle: const TextStyle(
        color: bone,
        fontWeight: FontWeight.bold,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mountain == null
              ? const Center(child: Text('Mountain not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mountain Name
                      Text(
                        _mountain!.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kombuGreen,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.height,
                              'Height',
                              '${_mountain!.heightMdpl} mdpl',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              Icons.location_on,
                              'Province',
                              _mountain!.province,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.calendar_today,
                              'Min Booking',
                              '${_mountain!.minBook} days',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              Icons.check_circle_outline,
                              'Status',
                              _mountain!.availability ? 'Available' : 'Closed',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description Section
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cafeNoir,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _mountain!.description.isNotEmpty
                            ? _mountain!.description
                            : 'No description available.',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Book Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _mountain!.availability
                              ? () {
                                  final request = context.read<CookieRequest>();
                                  if (!request.loggedIn) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please login to book this mountain.')),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingFormPage(
                                        mountainId: _mountain!.id.toString(),
                                        mountainName: _mountain!.name,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.book_online),
                          label: Text(_mountain!.availability ? 'Book This Mountain' : 'Not Available'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kombuGreen,
                            foregroundColor: bone,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: cafeNoir, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
