import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phr/data/services/settings_service.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  List<Map<String, String>> contacts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    contacts.clear();

    for (int i = 1; i <= 10; i++) {
      final data = await SettingsService.get("emergency_contact_$i");
      if (data != null && data.isNotEmpty) {
        contacts.add(Map<String, String>.from(jsonDecode(data)));
      }
    }

    setState(() => loading = false);
  }

  Future<void> saveContacts() async {
    for (int i = 0; i < contacts.length; i++) {
      await SettingsService.save(
        "emergency_contact_${i + 1}",
        jsonEncode(contacts[i]),
      );
    }

    for (int i = contacts.length + 1; i <= 10; i++) {
      await SettingsService.save("emergency_contact_$i", "");
    }

    Navigator.pop(context, true);
  }

  void openContactEditor({Map<String, String>? contact, int? index}) {
    final nameCtrl = TextEditingController(text: contact?["name"]);
    final phoneCtrl = TextEditingController(text: contact?["phone"]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                index == null ? "Add Emergency Contact" : "Edit Contact",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _field("Name", nameCtrl, Icons.person),
              _field(
                "Phone Number",
                phoneCtrl,
                Icons.phone,
                type: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;

                    final newContact = {
                      "name": nameCtrl.text,
                      "phone": phoneCtrl.text,
                    };

                    setState(() {
                      if (index != null) {
                        contacts[index] = newContact;
                      } else {
                        contacts.add(newContact);
                      }
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteContact(int index) {
    setState(() => contacts.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
            ),
          ),
        ),
        title: const Text("Emergency Contacts"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: saveContacts),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        child: const Icon(Icons.add),
        onPressed: () => openContactEditor(),
      ),

      body: contacts.isEmpty
          ? const Center(
              child: Text(
                "No emergency contacts.\nTap + to add one.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: contacts.length,
              itemBuilder: (_, index) {
                final c = contacts[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFFDE0DC),
                        child: Icon(Icons.person, color: Color(0xFFD32F2F)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c["name"] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c["phone"] ?? "",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            openContactEditor(contact: c, index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => deleteContact(index),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF2F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
