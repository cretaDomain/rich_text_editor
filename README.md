# Creta Rich Text Editor

A feature-rich and highly customizable rich text editor for Flutter that supports real-time preview, JSON import/export, and a wide range of text styling options.

![example](https://raw.githubusercontent.com/cretaDomain/rich_text_editor/refs/heads/main/preview.png)


## Features

- **100% Flutter code!** : It's native flutter, not using java script.
- **Real-time WYSIWYG-like Preview**: See your changes instantly in a live preview pane while editing.
- **Dynamic Toolbar**: Responsive toolbar that adapts its layout to the available width.
- **Extensive Styling**:
  - Font family and size
  - Bold, italic, underline
  - Text color and alignment
  - Letter and line spacing
  - Shadow and outline effects
- **JSON Import/Export**: Easily serialize editor content to and from JSON for easy storage and retrieval.
- **Customizable UI**:
  - Set initial dimensions (`width`, `height`).
  - Customize background colors and padding.
  - Show or hide the title bar.
  - Provide a custom list of fonts.

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  creta_rich_text_editor: ^1.0.3
```

Then, import the library in your Dart code:

```dart
import 'package:creta_rich_text_editor/creta_rich_text_editor.dart';
```

## Usage

Here's a basic example of how to use the `RichTextEditor`:

```dart
import 'package:flutter/material.dart';
import 'package:creta_rich_text_editor/creta_rich_text_editor.dart';

class MyEditorPage extends StatefulWidget {
  @override
  _MyEditorPageState createState() => _MyEditorPageState();
}

class _MyEditorPageState extends State<MyEditorPage> {
  late final RichTextEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichTextEditorController();
    
    // Set initial content from a JSON string
    Future.microtask(() {
      const sampleJson = '''
      {
        "spans": [
          {"text": "Hello, ", "attribute": {"fontSize": 18.0}},
          {"text": "World!", "attribute": {"fontSize": 24.0, "fontWeight": "FontWeight.bold"}}
        ]
      }
      ''';
      _controller.setDocumentFromJsonString(sampleJson);
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Creta Editor')),
      body: Center(
        child: RichTextEditor(
          controller: _controller,
          width: 400,
          height: 300,
          fontList: const ['Roboto', 'Arial', 'Courier'],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get content as a JSON map
          final jsonMap = _controller.document.toJson();
          print(jsonMap);
        },
        child: Icon(Icons.data_object),
      ),
    );
  }
}
```

## Additional Information

- The project is open-source and contributions are welcome.
- Please file issues and feature requests on the [GitHub repository](https://github.com/your_username/creta_rich_text_editor). <!-- TODO: Update URL -->
