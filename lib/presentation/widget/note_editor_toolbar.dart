import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditorToolbar extends StatelessWidget {
  final QuillController controller;

  const NoteEditorToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: QuillSimpleToolbar(
          controller: controller,
          config: const QuillSimpleToolbarConfig(
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showListBullets: true,
            showListNumbers: true,

            showStrikeThrough: false,
            showInlineCode: false,
            showFontSize: false,
            showFontFamily: false,
            showColorButton: false,
            showBackgroundColorButton: false,
            showListCheck: false,
            showCodeBlock: false,
            showQuote: false,
            showIndent: false,
            showLink: false,
            showAlignmentButtons: false,
            showDirection: false,
            showUndo: false,
            showRedo: false,
            showClearFormat: false,
            showSearchButton: false,
          ),
        ),
      ),
    );
  }
}
