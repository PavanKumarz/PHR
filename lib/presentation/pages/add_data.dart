import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:intl/intl.dart';

import 'package:phr/data/models/note_model.dart';
import 'package:phr/data/models/table_row_data.dart';
import 'package:phr/data/datasources/database_helper.dart';
import 'package:phr/data/services/voice_manager.dart';

import 'package:phr/presentation/widget/add_data_title_bar.dart';
import 'package:phr/presentation/widget/add_data_fab_menu.dart';
import 'package:phr/presentation/widget/table_editor.dart';
import 'package:phr/presentation/widget/audio_record_sheet.dart';
import 'package:phr/presentation/widget/audio_player_widget.dart';
import 'package:phr/presentation/widget/picked_file_preview.dart';
import 'package:phr/presentation/widget/note_editor_toolbar.dart';
import 'package:phr/presentation/pages/note_editor_page.dart';

enum NoteViewMode { text, table }

class AddData extends StatefulWidget {
  final NoteModel? existingNote;
  const AddData({super.key, this.existingNote});

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  QuillController? _controller;
  final TextEditingController _titleController = TextEditingController();

  final VoiceManager _voiceManager = VoiceManager();

  NoteViewMode viewMode = NoteViewMode.text;

  List<String> tableColumns = ['Date', 'Value', 'Notes'];
  List<TableRowData> tableRows = [];

  List<String> pickedFiles = [];
  List<String> audioFiles = [];

  NoteModel? currentNote;

  @override
  void initState() {
    super.initState();
    _initEditor();
  }

  Future<void> _initEditor() async {
    _controller = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );

    if (widget.existingNote != null) {
      final n = widget.existingNote!;
      currentNote = n;

      _titleController.text = n.title;
      viewMode = n.viewMode == 'table' ? NoteViewMode.table : NoteViewMode.text;

      pickedFiles = List<String>.from(n.files);
      audioFiles = List<String>.from(n.audio);

      try {
        final decoded = jsonDecode(n.tableData);
        tableColumns = List<String>.from(decoded['columns'] ?? tableColumns);
        tableRows = (decoded['rows'] as List)
            .map((e) => TableRowData.fromMap(e))
            .toList();
      } catch (_) {}

      if (tableRows.isEmpty) tableRows.add(TableRowData());

      try {
        final delta = Delta.fromJson(jsonDecode(n.text));
        _controller = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {}
    } else {
      tableRows.add(TableRowData());
    }

    setState(() {});
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null) return;

    setState(() {
      pickedFiles.addAll(
        result.files.where((f) => f.path != null).map((f) => f.path!).toList(),
      );
    });
  }

  Future<void> saveNote() async {
    final note = NoteModel(
      id: currentNote?.id,
      title: _titleController.text.trim(),
      text: jsonEncode(_controller!.document.toDelta().toJson()),
      tableData: jsonEncode({
        'columns': tableColumns,
        'rows': tableRows.map((e) => e.toMap()).toList(),
      }),
      viewMode: viewMode.name,
      files: pickedFiles,
      audio: audioFiles,
      date: DateFormat('dd MMM yyyy').format(DateTime.now()),
    );

    if (currentNote == null) {
      final id = await DatabaseHelper.instance.insertNote(note);
      currentNote = await DatabaseHelper.instance.getNoteById(id);
    } else {
      await DatabaseHelper.instance.updateNote(note);
      currentNote = await DatabaseHelper.instance.getNoteById(note.id!);
    }

    if (!mounted) return;
    Navigator.pop(context, currentNote);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentNote == null ? "Add Data" : "Edit Data"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: saveNote),
        ],
      ),
      body: Column(
        children: [
          AddDataTitleBar(
            controller: _titleController,
            date: DateFormat('dd MMM yyyy').format(DateTime.now()),
          ),

          _modeSwitcher(),

          Expanded(
            child: ListView(
              children: [
                if (viewMode == NoteViewMode.text)
                  NoteEditorPage(controller: _controller!)
                else
                  SizedBox(
                    height: 400,
                    child: TableEditor(
                      columns: tableColumns,
                      rows: tableRows,
                      onAddRow: () =>
                          setState(() => tableRows.add(TableRowData())),
                      onDeleteRow: (i) => setState(() => tableRows.removeAt(i)),
                      onAddColumn: _addColumn,
                      onDeleteColumn: _deleteColumn,
                    ),
                  ),

                const SizedBox(height: 10),

                for (int i = 0; i < pickedFiles.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: PickedFilePreview(
                      filePath: pickedFiles[i],
                      onRemove: () => setState(() => pickedFiles.removeAt(i)),
                    ),
                  ),

                for (int i = 0; i < audioFiles.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AudioPlayerWidget(
                      filePath: audioFiles[i],
                      index: i,
                      onRemove: () => setState(() => audioFiles.removeAt(i)),
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          if (viewMode == NoteViewMode.text)
            NoteEditorToolbar(controller: _controller!),
        ],
      ),

      floatingActionButton: AddDataFabMenu(
        note: currentNote,

        onPickDoc: _pickDocument,

        onVoiceRecord: () async {
          await _voiceManager.startRecording();

          showModalBottomSheet(
            context: context,
            isDismissible: false,
            builder: (_) => AudioRecordSheet(
              voiceManager: _voiceManager,
              onSave: (path) {
                setState(() => audioFiles.add(path));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _modeSwitcher() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SegmentedButton<NoteViewMode>(
        segments: const [
          ButtonSegment(
            value: NoteViewMode.text,
            label: Text("Note"),
            icon: Icon(Icons.edit),
          ),
          ButtonSegment(
            value: NoteViewMode.table,
            label: Text("Table"),
            icon: Icon(Icons.table_chart),
          ),
        ],
        selected: {viewMode},
        onSelectionChanged: (v) => setState(() => viewMode = v.first),
      ),
    );
  }

  Future<void> _addColumn() async {
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Column"),
        content: TextField(controller: c),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    setState(() {
      tableColumns.add(name);
      for (final r in tableRows) {
        r.cells[name] = '';
      }
    });
  }

  void _deleteColumn(String col) {
    setState(() {
      tableColumns.remove(col);
      for (final r in tableRows) {
        r.cells.remove(col);
      }
    });
  }
}
