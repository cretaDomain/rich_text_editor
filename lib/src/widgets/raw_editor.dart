import 'package:flutter/material.dart';
import '../controllers/rich_text_editor_controller.dart';

/// A raw text editor that displays rich text content and handles user input.
///
/// This widget is responsible for painting the text and managing input
/// directly, without relying on a `TextFormField`.
class RawEditor extends StatefulWidget {
  const RawEditor({
    super.key,
    required this.controller,
  });

  /// The controller that manages the document and selection.
  final RichTextEditorController controller;

  @override
  State<RawEditor> createState() => _RawEditorState();
}

class _RawEditorState extends State<RawEditor> {
  @override
  Widget build(BuildContext context) {
    // The CustomPaint widget is the canvas where the rich text will be drawn.
    // For now, it's empty, but it will soon be powered by a CustomPainter.
    return CustomPaint(
      // The painter will be implemented in the next step.
      // painter: DocumentPainter(
      //   document: widget.controller.document,
      // ),
      size: Size.infinite,
    );
  }
}
