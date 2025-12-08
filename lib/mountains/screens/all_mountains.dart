import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/booking/screens/booking_form_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
// booking_form_page import removed to avoid circular import; navigation to booking uses named route '/booking'
import '../../userprofile/screens/login.dart';
import 'mountain_details.dart';
import '../../widgets/base_scaffold.dart';
import '../models/mountain.dart';

class AllMountainsPage extends StatefulWidget {
  const AllMountainsPage({super.key});

  @override
  State<AllMountainsPage> createState() => _AllMountainsPageState();
}

class _AllMountainsPageState extends State<AllMountainsPage> {
  List<Mountain> _mountains = [];
  List<Mountain> _filteredMountains = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedProvince = '';
  String _heightRange = '';
  String _sortBy = 'name';
  List<String> _provinces = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMountains();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMountains() async {
    setState(() => _isLoading = true);
    
    final request = context.read<CookieRequest>();
    try {
      print('Fetching mountains from: http://localhost:8000/mountains/api/mountains/');
      final response = await request.get(
        'http://localhost:8000/mountains/api/mountains/?search=$_searchQuery&province=$_selectedProvince&height_range=$_heightRange&sort=$_sortBy',
      );
      
      print('Response received: $response');
      print('Response type: ${response.runtimeType}');
      
      if (response != null && response['mountains'] != null) {
        final List<dynamic> mountainsJson = response['mountains'];
        print('Found ${mountainsJson.length} mountains');
        setState(() {
          _mountains = mountainsJson.map((json) => Mountain.fromJson(json)).toList();
          _filteredMountains = _mountains;
          
          // Extract unique provinces
          _provinces = _mountains.map((m) => m.province).toSet().toList()..sort();
          _isLoading = false;
        });
      } else {
        print('Response is null or missing mountains key');
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No mountains found in response')),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error fetching mountains: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading mountains: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _fetchMountains();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedProvince = '';
      _heightRange = '';
      _sortBy = 'name';
      _searchController.clear();
    });
    _fetchMountains();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'All Mountains',
      backgroundColor: Colors.white,
      appBarBackgroundColor: const Color(0xFF2E7D32),
      appBarElevation: 0,
      appBarIconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        onSubmitted: (_) => _applyFilters(),
                        decoration: InputDecoration(
                          hintText: 'Search mountains...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF2E7D32), // Green
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.tune,
                              color: Color(0xFF5D4037), // Brown
                            ),
                            onPressed: () => _showFilterDialog(),
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
          _filteredMountains.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No mountains found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _filteredMountains.map((m) {
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
                                  child: m.imageUrl.isNotEmpty
                                      ? Image.network(
                                          m.imageUrl,
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
                                        )
                                      : Container(
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.terrain,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
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
                                        m.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32), // Green
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Province
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 18,
                                            color: Color(0xFF5D4037), // Brown
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            m.province,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
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
                                            '${m.heightMdpl} MDPL',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Experience Required
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            m.experienceRequired,
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
                                                      mountainId: m.id,
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
                                              onPressed: m.availability
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
                                                          const SnackBar(content: Text('Silakan login untuk melakukan booking.')),
                                                        );
                                                        return;
                                                      }

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => BookingFormPage(
                                                            mountainId: m.id.toString(),
                                                            mountainName: m.name,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF2E7D32), // Green
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                m.availability ? 'Book' : 'Not Available',
                                                style: const TextStyle(
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Province filter
                const Text('Province', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedProvince.isEmpty ? null : _selectedProvince,
                  hint: const Text('Select Province'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Provinces')),
                    ..._provinces.map((p) => DropdownMenuItem(value: p, child: Text(p))),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _selectedProvince = value ?? '');
                  },
                ),
                const SizedBox(height: 16),

                // Height range filter
                const Text('Height Range', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _heightRange.isEmpty ? null : _heightRange,
                  hint: const Text('Select Height Range'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Heights')),
                    DropdownMenuItem(value: '0-1000', child: Text('< 1000 MDPL')),
                    DropdownMenuItem(value: '1000-2000', child: Text('1000-2000 MDPL')),
                    DropdownMenuItem(value: '2000-3000', child: Text('2000-3000 MDPL')),
                    DropdownMenuItem(value: '3000-4000', child: Text('> 3000 MDPL')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _heightRange = value ?? '');
                  },
                ),
                const SizedBox(height: 16),

                // Sort by
                const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name (A-Z)')),
                    DropdownMenuItem(value: '-name', child: Text('Name (Z-A)')),
                    DropdownMenuItem(value: 'height_mdpl', child: Text('Height (Low to High)')),
                    DropdownMenuItem(value: '-height_mdpl', child: Text('Height (High to Low)')),
                    DropdownMenuItem(value: 'province', child: Text('Province')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _sortBy = value ?? 'name');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedProvince = '';
                  _heightRange = '';
                  _sortBy = 'name';
                });
                _clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                _applyFilters();
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}