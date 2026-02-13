import 'package:flutter/material.dart';
import 'package:phr/data/models/note_model.dart';
import 'package:phr/presentation/pages/add_data.dart';
import 'package:phr/presentation/pages/more/cardPages/medical_cards_page.dart';
import 'package:phr/presentation/pages/more_page.dart';
import 'package:phr/presentation/pages/more/cardPages/bp_tracking_page.dart';
import 'package:phr/presentation/pages/more/cardPages/sugar_tracking_page.dart';
import 'package:phr/presentation/pages/more/cardPages/weight_tracking_page.dart';
import 'package:phr/presentation/pages/records_page.dart';
import 'package:phr/presentation/widget/home_cards_strip_part.dart';
import 'package:phr/data/datasources/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NoteModel> savedNotes = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await DatabaseHelper.instance.getNotes();
    setState(() => savedNotes = notes);
  }

  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _loadNotes();
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Note?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteNote(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Records"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        elevation: 4,
        child: const Icon(Icons.add),
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddData()),
          );
          if (newNote != null) {
            _loadNotes();
          }
        },
      ),

      body: _currentIndex == 0
          ? _homeContent()
          : _currentIndex == 1
          ? RecordsPage(
              notes: savedNotes,
              onDelete: _confirmDelete,
              onRefresh: _loadNotes,
            )
          : const MorePage(),
    );
  }

  Widget _homeContent() {
    return Column(
      children: [
        _header(),
        const SizedBox(height: 18),

        StripPart(
          onAddBP: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BPTrackingPage()),
          ),
          onAddSugar: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SugarTrackingPage()),
          ),
          onAddWeight: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeightTrackingPage()),
          ),
          onAddMedicalCards: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MedicalcardsPage()),
          ),
        ),

        const SizedBox(height: 18),

        Expanded(
          child: savedNotes.isEmpty
              ? const Center(
                  child: Text(
                    "No data yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: savedNotes.length,
                  itemBuilder: (_, i) => _homeNoteCard(savedNotes[i]),
                ),
        ),
      ],
    );
  }

  Widget _homeNoteCard(NoteModel note) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddData(existingNote: note)),
        );
        if (updated != null) _loadNotes();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  note.viewMode == 'table'
                      ? Icons.table_chart
                      : Icons.edit_note,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    note.title.isEmpty ? "(No Title)" : note.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Last Updated • ${note.date}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: 210,
            width: double.infinity,
            child: Image.asset(
              'assets/images/head.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Container(
            height: 210,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Positioned(
            left: 20,
            bottom: 24,
            child: Text(
              "Your Journey to Wellness",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w100,
                fontFamily: 'Fredoka',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
