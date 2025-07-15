//import 'dart:convert';
import 'package:flutter/material.dart';
import 'src/controllers/rich_text_editor_controller.dart';
import 'src/widgets/rich_text_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rich Text Editor Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Rich Text Editor Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late RichTextEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichTextEditorController();

    Future.microtask(() {
      const sampleJsonString = '''
      {
          "document": {
              "spans": [
                  {
                      "text": "Hello, Rich Text Editor! 12345 678901234\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  },
                  {
                      "text": "Hello, Rich TextEditor!1\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  },
                  {
                      "text": "Hello, Rich TextEditor!2\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  },
                  {
                      "text": "Hello, Rich TextEditor!3\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  },
                  {
                      "text": "Hello, Rich TextEditor!4\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  },
                  {
                      "text": "Hello, Rich TextEditor!5\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  },
                  {
                      "text": "Hello, Rich TextEditor!6\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  },
                  {
                      "text": "Hello, Rich TextEditor!7\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  },
                  {
                      "text": "Hello, Rich TextEditor!8\\n",
                      "attribute": {
                          "fontSize": 24,
                          "color": 4278190080
                      }
                  }
              ],
              "textAlign": "center"
          },
          "padding": {
              "left": 16,
              "top": 16,
              "right": 16,
              "bottom": 16
          }
      }
      ''';
      _controller.setDocumentFromJsonString(sampleJsonString);
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: RichTextEditor(
          showToolbar: true,
          initialMode: EditorMode.edit,
          fontList: const ['Roboto', 'Arial', 'Courier', 'Long name font...'],
          showTitleBar: false,
          width: 900,
          height: 200,
          controller: _controller,
          onEditCompleted: (json) {
            //print('-----------------------------------------------------------');
            // ignore: avoid_print
            print('onEditCompleted: $json');
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // 컨트롤러에서 문서의 JSON 표현을 가져옵니다.
      //     final jsonMap = _controller.document.toJson();
      //     // jsonEncode를 사용하여 Dart 맵을 사람이 읽기 좋은 형식의 JSON 문자열로 변환합니다.
      //     final jsonString = jsonEncode(jsonMap, toEncodable: (e) => e.toString());
      //     // ignore: avoid_print
      //     print(jsonString);
      //   },
      //   tooltip: 'Print JSON',
      //   child: const Icon(Icons.data_object),
      // ),
    );
  }
}
