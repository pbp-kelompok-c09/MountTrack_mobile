import 'package:flutter/material.dart';
import '../../widgets/app_navbar.dart';

class MountainDetailsPage extends StatelessWidget {
  final String id;
  final String name;
  final String height;
  final String description;

  const MountainDetailsPage({
    super.key,
    required this.id,
    required this.name,
    required this.height,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: name),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(height, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(description),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open route / map (not implemented)')),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Open Map'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Save to favorites (not implemented)')),
                    );
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Favorite'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
