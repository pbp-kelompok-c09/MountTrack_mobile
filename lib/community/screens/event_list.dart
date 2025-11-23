import 'package:flutter/material.dart';
import 'package:mounttrack_mobile/community/screens/event_create.dart';


class CommunityEventListPage extends StatelessWidget {
  const CommunityEventListPage({super.key});

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

            // LIST KOSONG (belum ada data)
            const Expanded(
              child: Center(
                child: Text(
                  "Belum ada event",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityEventCreatePage(),
          ),
    );
  },
  child: const Icon(Icons.add),
),

    );
  }
}
