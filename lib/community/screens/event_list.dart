import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../config.dart';
import '../models/community_event.dart';
import 'event_create.dart';
import 'event_detail.dart';
import '../community_theme.dart';

class CommunityEventListPage extends StatefulWidget {
  const CommunityEventListPage({super.key});

  @override
  State<CommunityEventListPage> createState() => _CommunityEventListPageState();
}

class _CommunityEventListPageState extends State<CommunityEventListPage> {
  final searchC = TextEditingController();
  String status = ''; // ''=All, OPEN, FULL, DRAFT
  String difficulty = ''; // ''=All, BEGINNER, INTERMEDIATE, ADVANCED
  List<CommunityEvent> _events = [];
  bool _isLoading = false;

  static const kombuGreen = Color(0xFF354024);
  static const bone = Color(0xFFE5D7C4);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchEvents());
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    
    try {
      final queryParams = <String>[];
      if (searchC.text.trim().isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(searchC.text.trim())}');
      }
      if (status.isNotEmpty) {
        queryParams.add('status=$status');
      }
      if (difficulty.isNotEmpty) {
        queryParams.add('difficulty=$difficulty');
      }
      
      final url = '${AppConfig.baseUrl}/community/${queryParams.isEmpty ? '' : '?${queryParams.join('&')}'}';
      print('Fetching events from: $url');
      
      final response = await request.get(url);
      print('Response type: ${response.runtimeType}');
      
      List<dynamic> eventsList;
      
      if (response is List) {
        // Direct list response
        eventsList = response;
      } else if (response is Map && response.containsKey('events')) {
        // Wrapped response with events field
        eventsList = response['events'] as List;
      } else {
        throw Exception('Unexpected response format');
      }
      
      setState(() {
        _events = eventsList.map((e) => CommunityEvent.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchEvents,
            ),
          ),
        );
      }
    }
  }

  List<CommunityEvent> get filtered {
    return _events..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered;

    return Theme(
      data: CommunityTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Community Events",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: bone,
            ),
          ),
          backgroundColor: kombuGreen,
          foregroundColor: bone,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: bone),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: searchC,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Cari event (gunung / judul)...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _fetchEvents(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "", child: Text("All")),
                        DropdownMenuItem(value: "OPEN", child: Text("Open")),
                        DropdownMenuItem(value: "FULL", child: Text("Full")),
                        DropdownMenuItem(value: "DRAFT", child: Text("Draft")),
                      ],
                      onChanged: (v) {
                        setState(() => status = v ?? '');
                        _fetchEvents();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: difficulty,
                      decoration: const InputDecoration(
                        labelText: "Difficulty",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "", child: Text("All")),
                        DropdownMenuItem(value: "BEGINNER", child: Text("Beginner")),
                        DropdownMenuItem(value: "INTERMEDIATE", child: Text("Intermediate")),
                        DropdownMenuItem(value: "ADVANCED", child: Text("Advanced")),
                      ],
                      onChanged: (v) {
                        setState(() => difficulty = v ?? '');
                        _fetchEvents();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        searchC.clear();
                        setState(() {
                          status = '';
                          difficulty = '';
                        });
                        _fetchEvents();
                      },
                      child: const Text("Reset Filter"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? const Center(child: Text("Belum ada event"))
                        : RefreshIndicator(
                            onRefresh: _fetchEvents,
                            child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final e = items[index];
                          final kuota = "${e.confirmedCount()}/${e.capacity}";
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text("${e.mountainName}\n${_fmtRange(e.startAt, e.endAt)}\nKuota: $kuota"),
                              isThreeLine: true,
                              trailing: Text(e.status),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CommunityEventDetailPage(eventId: e.id)),
                                );
                                _fetchEvents();
                              },
                            ),
                          );
                        },
                      ),
                    ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityEventCreatePage()));
            _fetchEvents();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _fmtRange(DateTime start, DateTime? end) {
    String two(int x) => x.toString().padLeft(2, '0');
    String fmt(DateTime d) => "${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}";
    if (end != null && (end.year != start.year || end.month != start.month || end.day != start.day)) {
      return "${fmt(start)} – ${fmt(end)}";
    }
    return fmt(start);
  }
}
