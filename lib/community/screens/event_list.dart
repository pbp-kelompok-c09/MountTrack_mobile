import 'package:flutter/material.dart';
import '../models/community_event.dart';
import 'event_create.dart';
import 'event_detail.dart';
import 'event_store.dart';

class CommunityEventListPage extends StatefulWidget {
  const CommunityEventListPage({super.key});

  @override
  State<CommunityEventListPage> createState() => _CommunityEventListPageState();
}

class _CommunityEventListPageState extends State<CommunityEventListPage> {
  final searchC = TextEditingController();
  String status = ''; // ''=All, OPEN, FULL, DRAFT
  String difficulty = ''; // ''=All, BEGINNER, INTERMEDIATE, ADVANCED

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  List<CommunityEvent> get filtered {
    final q = searchC.text.trim().toLowerCase();

    return EventStore.events.where((e) {
      if (e.status == 'CANCELLED') return false; // sesuai Django list exclude CANCELLED

      final matchSearch = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.mountainName.toLowerCase().contains(q);

      final matchStatus = status.isEmpty || e.status == status;
      final matchDifficulty = difficulty.isEmpty || e.difficulty == difficulty;

      return matchSearch && matchStatus && matchDifficulty;
    }).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Events"),
        centerTitle: true,
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
              onChanged: (_) => setState(() {}),
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
                    onChanged: (v) => setState(() => status = v ?? ''),
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
                    onChanged: (v) => setState(() => difficulty = v ?? ''),
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
                    },
                    child: const Text("Reset Filter"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("Belum ada event"))
                  : ListView.builder(
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
                                MaterialPageRoute(builder: (_) => CommunityEventDetailPage(event: e)),
                              );
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityEventCreatePage()));
          setState(() {});
        },
        child: const Icon(Icons.add),
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
