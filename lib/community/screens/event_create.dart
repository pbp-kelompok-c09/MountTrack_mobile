import 'package:flutter/material.dart';

class CommunityEventCreatePage extends StatefulWidget {
  const CommunityEventCreatePage({super.key});

  @override
  State<CommunityEventCreatePage> createState() => _CommunityEventCreatePageState();
}

class _CommunityEventCreatePageState extends State<CommunityEventCreatePage> {
  final titleC = TextEditingController();
  final mountainC = TextEditingController();
  final startAtC = TextEditingController();
  final endAtC = TextEditingController();
  final capacityC = TextEditingController();
  final priceC = TextEditingController();
  final meetingPointC = TextEditingController();
  final contactC = TextEditingController();
  final descriptionC = TextEditingController();

  String difficulty = "BEGINNER";
  String status = "OPEN";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            inputField("Judul Event", titleC),
            inputField("Nama Gunung", mountainC),
            inputField("Start At (datetime)", startAtC),
            inputField("End At (datetime optional)", endAtC),
            inputField("Capacity", capacityC, type: TextInputType.number),
            inputField("Price", priceC, type: TextInputType.number),

            dropdownField(
              label: "Difficulty",
              value: difficulty,
              items: const [
                "BEGINNER",
                "INTERMEDIATE",
                "ADVANCED",
              ],
              onChanged: (v) => setState(() => difficulty = v!),
            ),

            inputField("Meeting Point", meetingPointC),
            inputField("Contact Person", contactC),
            textAreaField("Description", descriptionC),

            dropdownField(
              label: "Status",
              value: status,
              items: const [
                "DRAFT",
                "OPEN",
              ],
              onChanged: (v) => setState(() => status = v!),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Untuk sekarang hanya print data
                  print("Event Created");
                },
                child: const Text("Create Event"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget inputField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        keyboardType: type,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget textAreaField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
