import 'package:flutter/material.dart';
import 'mountain_details.dart';

class AllMountainsPage extends StatelessWidget {
  const AllMountainsPage({super.key});

  // Sample data. Replace with real API calls via CookieRequest in future.
  List<Map<String, String>> get sampleMountains => const [
        {
          'id': '1',
          'name': 'Mount Everest',
          'height': '8,848 m',
          'summary': 'Highest mountain on Earth.',
        },
        {
          'id': '2',
          'name': 'K2',
          'height': '8,611 m',
          'summary': 'Second highest peak, very challenging.',
        },
        {
          'id': '3',
          'name': 'Kangchenjunga',
          'height': '8,586 m',
          'summary': 'Third highest peak.',
        },
      ];

  @override
  Widget build(BuildContext context) {
    final items = sampleMountains;

    return Scaffold(
      appBar: AppBar(title: const Text('All Mountains')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final m = items[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.terrain),
            ),
            title: Text(m['name'] ?? ''),
            subtitle: Text(m['height'] ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MountainDetailsPage(
                    id: m['id']!,
                    name: m['name']!,
                    height: m['height']!,
                    description: m['summary']!,
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: items.length,
      ),
    );
  }
}
