import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phr/data/models/medical_card_model.dart';
import 'package:phr/data/datasources/medical_cards_database.dart';

class MedicalcardsPage extends StatefulWidget {
  const MedicalcardsPage({super.key});

  @override
  State<MedicalcardsPage> createState() => _MedicalcardsPageState();
}

class _MedicalcardsPageState extends State<MedicalcardsPage> {
  List<MedicalCardModel> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    cards = await MedicalCardsDatabase.instance.getCards();
    setState(() {});
  }

  Future<void> _addCard() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final String newPath = join(dir.path, basename(picked.path));
    final File savedImage = await File(picked.path).copy(newPath);

    final card = MedicalCardModel(
      title: "Medical Card",
      imagePath: savedImage.path,
      date: DateTime.now().toIso8601String(),
    );

    await MedicalCardsDatabase.instance.insertCard(card);
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
          ),
        ),
        title: const Text("Medical Cards"),
      ),

      body: cards.isEmpty
          ? const Center(child: Text("No cards added"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (_, i) => _cardTile(cards[i]),
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _cardTile(MedicalCardModel card) {
    return GestureDetector(
      onTap: () async {
        await OpenFilex.open(card.imagePath);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.file(
                  File(card.imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                card.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
