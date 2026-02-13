import 'package:flutter/material.dart';
import 'package:phr/data/models/note_model.dart';
import 'package:phr/data/services/export_service.dart';
import 'package:phr/utils/export_dialog.dart';

class AddDataFabMenu extends StatefulWidget {
  final VoidCallback onPickDoc;
  final VoidCallback onVoiceRecord;
  final NoteModel? note;

  const AddDataFabMenu({
    super.key,
    required this.onPickDoc,
    required this.onVoiceRecord,
    required this.note,
  });

  @override
  State<AddDataFabMenu> createState() => _AddDataFabMenuState();
}

class _AddDataFabMenuState extends State<AddDataFabMenu>
    with TickerProviderStateMixin {
  bool showImport = false;
  bool showExport = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: Visibility(
                visible: showExport,
                child: Row(
                  children: [
                    _miniAction(
                      icon: Icons.picture_as_pdf,
                      color: Colors.red,
                      label: "PDF",
                      onTap: _onExportPdf,
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: "export_fab",
              backgroundColor: widget.note == null
                  ? Colors.grey
                  : Colors.purple,
              onPressed: () {
                setState(() {
                  showExport = !showExport;
                  showImport = false;
                });
              },
              child: Icon(showExport ? Icons.close : Icons.upload_file),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: Visibility(
                visible: showImport,
                child: Row(
                  children: [
                    _miniAction(
                      icon: Icons.mic,
                      color: Colors.orange,
                      label: "Voice",
                      onTap: widget.onVoiceRecord,
                    ),
                    const SizedBox(width: 10),
                    _miniAction(
                      icon: Icons.attach_file,
                      color: Colors.blue,
                      label: "File",
                      onTap: widget.onPickDoc,
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: "import_fab",
              backgroundColor: Colors.blue,
              onPressed: () {
                setState(() {
                  showImport = !showImport;
                  showExport = false;
                });
              },
              child: Icon(showImport ? Icons.close : Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onExportPdf() async {
    if (widget.note == null) {
      _snack("Please save the note first");
      return;
    }

    final type = await showPdfExportDialog(context);
    if (type == null) return;

    await ExportService.savePDF(widget.note!, type);

    if (!mounted) return;
    _snack("PDF exported successfully");

    setState(() {
      showExport = false;
    });
  }

  Widget _miniAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          onTap();
          setState(() {
            showExport = false;
            showImport = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
