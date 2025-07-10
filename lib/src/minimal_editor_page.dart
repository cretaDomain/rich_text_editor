import 'package:flutter/material.dart';
import '../controllers/rich_text_editor_controller.dart';
import '../widgets/raw_editor.dart';

/// A page that displays the RawEditor in isolation for focused debugging.
class MinimalEditorPage extends StatefulWidget {
  const MinimalEditorPage({super.key});

  @override
  State<MinimalEditorPage> createState() => _MinimalEditorPageState();
}

class _MinimalEditorPageState extends State<MinimalEditorPage> {
  late final RichTextEditorController _controller;

  @override
  void initState() {
    super.initState();
    // Pre-populate the editor with multi-line text for easy testing.
    _controller = RichTextEditorController(
      json: [
        {'insert': 'Line 1: Hello World\n'},
        {'insert': 'Line 2: This is a test\n'},
        {'insert': 'Line 3: Of the minimal editor\n'},
        {'insert': 'Line 4: With multiple lines\n'},
        {'insert': 'Line 5: To check arrow key navigation\n'},
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal Editor Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 400,
            height: 300,
            child: Material(
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RawEditor(controller: _controller),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
