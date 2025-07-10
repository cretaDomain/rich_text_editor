import 'package:flutter/material.dart';
import '../controllers/rich_text_editor_controller.dart';
import '../models/document_model.dart';

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
    return CustomPaint(
      painter: DocumentPainter(
        document: widget.controller.document,
      ),
      size: Size.infinite,
    );
  }
}

/// A custom painter that draws a `DocumentModel`.
class DocumentPainter extends CustomPainter {
  const DocumentPainter({
    required this.document,
  });

  /// The document to be painted.
  final DocumentModel document;

  @override
  void paint(Canvas canvas, Size size) {
    // In the next step, we will implement the logic to iterate through
    // the document's spans and draw them using TextPainter.
    final text = TextSpan(
      children: document.spans.map((s) => s.toTextSpan()).toList(),
    );

    final textPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      textAlign: document.textAlign,
    );

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant DocumentPainter oldDelegate) {
    // For now, we repaint whenever the document changes.
    // This can be optimized later.
    return oldDelegate.document != document;
  }
}
