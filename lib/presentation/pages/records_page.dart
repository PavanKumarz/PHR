import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:phr/data/models/note_model.dart';
import 'package:phr/presentation/pages/add_data.dart';

class RecordsPage extends StatefulWidget {
  final List<NoteModel> notes;
  final Function(int id) onDelete;
  final Future<void> Function() onRefresh;

  const RecordsPage({
    super.key,
    required this.notes,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  String searchQuery = "";
  String activeFilter = "All";

  String extractText(NoteModel note) {
    if (note.viewMode == 'table') {
      return "Table data";
    }

    try {
      final decoded = jsonDecode(note.text);
      return Document.fromDelta(Delta.fromJson(decoded)).toPlainText().trim();
    } catch (_) {
      return note.text.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.notes.where((note) {
      final title = note.title.toLowerCase();
      final content = extractText(note).toLowerCase();

      if (searchQuery.isNotEmpty &&
          !title.contains(searchQuery.toLowerCase()) &&
          !content.contains(searchQuery.toLowerCase())) {
        return false;
      }

      if (activeFilter == "Notes") {
        return note.viewMode == 'text';
      }
      if (activeFilter == "Tables") {
        return note.viewMode == 'table';
      }

      return true;
    }).toList();

    return Column(
      children: [
        AppBar(title: const Text("Records")),

        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search records...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 12),
              _chip("All"),
              _chip("Notes"),
              _chip("Tables"),
              const SizedBox(width: 12),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text("No records found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _recordCard(filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: activeFilter == label,
        selectedColor: Colors.blue,
        onSelected: (_) => setState(() => activeFilter = label),
      ),
    );
  }

  Widget _recordCard(NoteModel note) {
    final preview = extractText(note);

    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddData(existingNote: note)),
        );
        if (updated != null) {
          widget.onRefresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
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
                      : Icons.description,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    note.title.isEmpty ? "(Untitled)" : note.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onDelete(note.id!),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Last Updated — ${note.date}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              preview.isEmpty ? "No content" : preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
