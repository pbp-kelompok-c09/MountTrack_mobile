import 'package:flutter/material.dart';
import '../models/community_event.dart';
import '../models/comment.dart';
import '../models/event_join.dart';
import '../community_theme.dart';

class CommunityEventDetailPage extends StatefulWidget {
  final CommunityEvent event;
  const CommunityEventDetailPage({super.key, required this.event});

  @override
  State<CommunityEventDetailPage> createState() => _CommunityEventDetailPageState();
}

class _CommunityEventDetailPageState extends State<CommunityEventDetailPage> {
  final commentC = TextEditingController();
  final int currentUserId = 2; // dummy user login

  @override
  void dispose() {
    commentC.dispose();
    super.dispose();
  }

  void _snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  void _postComment() {
    final txt = commentC.text.trim();
    if (txt.isEmpty) return;

    final newId = (widget.event.comments.isEmpty ? 1 : widget.event.comments.first.id + 1);
    widget.event.comments.insert(
      0,
      Comment(
        id: newId,
        user: currentUserId,
        event: widget.event.id,
        body: txt,
        createdAt: DateTime.now(),
      ),
    );
    commentC.clear();
    setState(() {});
  }

  void _join() {
    final e = widget.event;

    if (e.status == 'CANCELLED' || e.status == 'DRAFT') {
      _snack("Event belum dibuka atau sudah dibatalkan.");
      return;
    }
    if (e.organizer == currentUserId) {
      _snack("Kamu adalah organizer event ini.");
      return;
    }

    final existing = e.joins.where((j) => j.user == currentUserId).toList();
    if (existing.isNotEmpty && existing.first.status == 'CONFIRMED') {
      _snack("Kamu sudah terdaftar sebagai peserta.");
      return;
    }

    if (existing.isEmpty) {
      e.joins.add(
        EventJoin(
          id: e.joins.length + 1,
          event: e.id,
          user: currentUserId,
          status: 'PENDING',
          joinedAt: DateTime.now(),
        ),
      );
    }

    final join = e.joins.firstWhere((j) => j.user == currentUserId);

    if (e.isFull()) {
      join.status = 'WAITLIST';
      _snack("Kapasitas penuh. Kamu masuk waitlist.");
    } else {
      join.status = 'CONFIRMED';
      _snack("Berhasil bergabung.");
    }

    e.recalcStatusAfterJoinChange();
    setState(() {});
  }

  void _leave() {
    final e = widget.event;

    final mine = e.joins.where((j) => j.user == currentUserId).toList();
    if (mine.isEmpty) {
      _snack("Kamu belum bergabung.");
      return;
    }

    mine.first.status = 'CANCELLED';

    // promote waitlist if event FULL
    final waiters = e.joins.where((j) => j.status == 'WAITLIST').toList()
      ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    if (e.status == 'FULL' && waiters.isNotEmpty) {
      waiters.first.status = 'CONFIRMED';
    }

    e.recalcStatusAfterJoinChange();
    _snack("Kamu sudah keluar dari event.");
    setState(() {});
  }

  void _cancelEvent() {
    final e = widget.event;
    if (e.organizer != currentUserId) {
      _snack("Hanya organizer yang bisa cancel.");
      return;
    }
    e.status = 'CANCELLED';
    _snack("Event dibatalkan.");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final kuota = "${e.confirmedCount()}/${e.capacity}";

    return Theme(
      data: CommunityTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Event Detail"),
          actions: [
            if (e.organizer == currentUserId)
              TextButton(
                onPressed: _cancelEvent,
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
        body: ListView(
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
                      subtitle: Text("User ${c.user} • ${c.createdAt.toLocal()}"),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
