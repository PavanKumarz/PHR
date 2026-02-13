import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditorPage extends StatelessWidget {
  final QuillController controller;

  const NoteEditorPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      controller: controller,
      focusNode: FocusNode(),
      scrollController: ScrollController(),
      config: const QuillEditorConfig(
        expands: false,
        scrollable: true,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        placeholder: "Write your note…",
        autoFocus: false,
      ),
    );
  }
}
