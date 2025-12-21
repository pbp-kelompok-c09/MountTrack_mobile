import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../config.dart';
import '../models/community_event.dart';
import '../community_theme.dart';

class CommunityEventDetailPage extends StatefulWidget {
  final int eventId;
  const CommunityEventDetailPage({super.key, required this.eventId});

  @override
  State<CommunityEventDetailPage> createState() => _CommunityEventDetailPageState();
}

class _CommunityEventDetailPageState extends State<CommunityEventDetailPage> {
  final commentC = TextEditingController();
  CommunityEvent? _event;
  bool _isLoading = false;
  String? _userJoinStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchEventDetail());
  }

  @override
  void dispose() {
    commentC.dispose();
    super.dispose();
  }

  Future<void> _fetchEventDetail() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.get('${AppConfig.baseUrl}/community/api/${widget.eventId}/');
      
      if (response is Map<String, dynamic>) {
        setState(() {
          _event = CommunityEvent.fromJson(response);
          _userJoinStatus = response['user_join_status'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _postComment() async {
    final txt = commentC.text.trim();
    if (txt.isEmpty) return;

    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        '${AppConfig.baseUrl}/community/api/${widget.eventId}/',
        {'body': txt},
      );

      if (response['status'] == 'success') {
        commentC.clear();
        _snack('Komentar berhasil ditambahkan');
        _fetchEventDetail();
      } else {
        _snack(response['message'] ?? 'Gagal menambahkan komentar');
      }
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> _join() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '${AppConfig.baseUrl}/community/api/${widget.eventId}/join/',
        {},
      );

      if (response['status'] == 'success') {
        _snack(response['message'] ?? 'Berhasil bergabung');
        _fetchEventDetail();
      } else {
        _snack(response['message'] ?? 'Gagal bergabung');
      }
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> _leave() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '${AppConfig.baseUrl}/community/api/${widget.eventId}/leave/',
        {},
      );

      if (response['status'] == 'success') {
        _snack(response['message'] ?? 'Berhasil keluar dari event');
        _fetchEventDetail();
      } else {
        _snack(response['message'] ?? 'Gagal keluar dari event');
      }
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> _cancelEvent() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '${AppConfig.baseUrl}/community/api/${widget.eventId}/cancel/',
        {},
      );

      if (response['status'] == 'success') {
        _snack('Event berhasil dibatalkan');
        _fetchEventDetail();
      } else {
        _snack(response['message'] ?? 'Gagal membatalkan event');
      }
    } catch (e) {
      _snack('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _event == null) {
      return Theme(
        data: CommunityTheme.theme,
        child: Scaffold(
          appBar: AppBar(title: const Text("Event Detail")),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final e = _event!;
    final kuota = "${e.confirmedCount()}/${e.capacity}";
    final request = context.watch<CookieRequest>();
    final isOrganizer = request.loggedIn && request.jsonData['id'] == e.organizer;

    return Theme(
      data: CommunityTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Event Detail"),
          actions: [
            if (isOrganizer)
              TextButton(
                onPressed: _cancelEvent,
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _fetchEventDetail,
          child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Gunung: ${e.mountainName}"),
                  Text("Mulai: ${e.startAt}"),
                  Text("Selesai: ${e.endAt ?? '-'}"),
                  Text("Kuota: $kuota"),
                  Text("Harga: ${e.price ?? '-'}"),
                  Text("Kesulitan: ${e.difficulty}"),
                  Text("Meeting Point: ${e.meetingPoint}"),
                  Text("Kontak: ${e.contactPerson}"),
                  Text("Status: ${e.status}"),
                  const SizedBox(height: 10),
                  Text("Deskripsi:\n${e.description}"),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _join, child: const Text("Join"))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: _leave, child: const Text("Leave"))),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Komentar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: commentC,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Tulis komentar...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _postComment, child: const Text("Kirim komentar")),
            ),
            const SizedBox(height: 12),
            if (e.comments.isEmpty)
              const Text("Belum ada komentar.")
            else
              ...e.comments.map((c) => Card(
                    child: ListTile(
                      title: Text(c.body),
                      subtitle: Text("${c.username ?? 'User ${c.user}'} • ${c.createdAt.toLocal()}"),
                    ),
                  )),
          ],
        ),
      ),
      ),
    );
  }
}
