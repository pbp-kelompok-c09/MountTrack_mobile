import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/community/screens/event_create.dart';

// GLOBAL LIST UNTUK MENYIMPAN EVENT YANG DIBUAT
List<Map<String, String>> eventList = [];

class CommunityEventListPage extends StatefulWidget {
  const CommunityEventListPage({super.key});

  @override
  State<CommunityEventListPage> createState() => _CommunityEventListPageState();
}

class _CommunityEventListPageState extends State<CommunityEventListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Events"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // SEARCH
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Cari event...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: eventList.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada event",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: eventList.length,
                      itemBuilder: (context, index) {
                        final item = eventList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"]!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Gunung: ${item['mountain']}"),
                                Text("Tanggal: ${item['start_at']}"),
                                Text("Tanggal Selesai: ${item['end_at']}"),
                                Text("Kapasitas: ${item['capacity']}"),
                                Text("Harga: ${item['price']}"),
                                Text("Kesulitan: ${item['difficulty']}"),
                                Text("Meeting Point: ${item['meeting_point']}"),
                                Text("Kontak: ${item['contact']}"),
                                Text("Deskripsi: ${item['description']}"),
                                Text("Status: ${item['status']}"),
                              ],
                            ),
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityEventCreatePage(),
            ),
          );
          setState(() {}); // refresh tampilan setelah create
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
