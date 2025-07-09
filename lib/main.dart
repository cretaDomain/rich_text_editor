import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rich_text_editor/src/controllers/rich_text_editor_controller.dart';
import 'package:rich_text_editor/src/models/document_model.dart';
import 'package:rich_text_editor/src/models/span_attribute.dart';
import 'package:rich_text_editor/src/models/text_span_model.dart';
import 'package:rich_text_editor/src/widgets/rich_text_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rich Text Editor Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Rich Text Editor Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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

    // Future.microtask를 사용하여 위젯의 첫 빌드가 완료된 후 데이터를 설정합니다.
    // 이렇게 하면 컨트롤러의 리스너가 준비된 상태에서 데이터 변경을 감지할 수 있습니다.
    Future.microtask(() {
      const sampleJsonString = '''
      {
    "spans": [
        {
            "text": "이것은 ",
            "attribute": {
                "fontSize": 16,
                "fontWeight": "FontWeight.w700",
                "color": 4294384668
            }
        },
        {
            "text": "",
            "attribute": {
                "fontSize": 14,
                "fontWeight": "FontWeight.w700",
                "color": 4294384668
            }
        },
        {
            "text": " 글씨와 ",
            "attribute": {
                "fontSize": 16,
                "fontWeight": "FontWeight.w700",
                "color": 4294384668
            }
        },
        {
            "text": "기",
            "attribute": {
                "fontSize": 16,
                "fontWeight": "FontWeight.w700",
                "fontStyle": "FontStyle.italic",
                "color": 4294384668
            }
        },
        {
            "text": "울임",
            "attribute": {
                "fontSize": 16,
                "fontStyle": "FontStyle.italic",
                "color": 4280391411
            }
        },
        {
            "text": " 글씨, 그리고 ",
            "attribute": {
                "fontSize": 16
            }
        },
        {
            "text": "기",
            "attribute": {
                "fontSize": 16,
                "fontWeight": "FontWeight.w700",
                "fontStyle": "FontStyle.italic",
                "color": 4294384668
            }
        },
        {
            "text": "울임",
            "attribute": {
                "fontSize": 16,
                "fontStyle": "FontStyle.italic",
                "color": 4280391411
            }
        },
        {
            "text": " 글씨, 그리고 ",
            "attribute": {
                "fontSize": 16
            }
        },
        {
            "text": "밑줄",
            "attribute": {
                "fontSize": 20,
                "color": 4294901760,
                "letterSpacing": 0,
                "decoration": "TextDecoration.underline"
            }
        },
        {
            "text": "을 포함하는 리치 텍스",
            "attribute": {
                "fontSize": 16,
                "letterSpacing": 0
            }
        },
        {
            "text": "트입니다.  가나다라 마바사아자차 카타파하.",
            "attribute": {
                "fontSize": 16
            }
        }
    ]
}
      ''';
      _controller.setDocumentFromJsonString(sampleJsonString);
    });

    // // 뷰 모드 렌더링을 테스트하기 위한 샘플 데이터 생성
    // final sampleDocument = DocumentModel(
    //   spans: [
    //     const TextSpanModel(
    //       text: '이것은 ',
    //       attribute: SpanAttribute(fontSize: 16),
    //     ),
    //     const TextSpanModel(
    //       text: '굵은',
    //       attribute: SpanAttribute(fontSize: 16, fontWeight: FontWeight.bold),
    //     ),
    //     const TextSpanModel(
    //       text: ' 글씨와 ',
    //       attribute: SpanAttribute(fontSize: 16),
    //     ),
    //     const TextSpanModel(
    //       text: '기울임',
    //       attribute: SpanAttribute(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.blue),
    //     ),
    //     const TextSpanModel(
    //       text: ' 글씨, 그리고 ',
    //       attribute: SpanAttribute(fontSize: 16),
    //     ),
    //     const TextSpanModel(
    //       text: '밑줄',
    //       attribute:
    //           SpanAttribute(fontSize: 20, decoration: TextDecoration.underline, color: Colors.red),
    //     ),
    //     const TextSpanModel(
    //       text: '을 포함하는 리치 텍스트입니다.',
    //       attribute: SpanAttribute(fontSize: 16),
    //     ),
    //   ],
    // );

    // // 컨트롤러에 샘플 데이터 설정
    // _controller.setDocument(sampleDocument);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichTextEditor(
            controller: _controller,
            title: 'My Custom Editor',
            width: 400,
            height: 300,
            backgroundColor: Colors.blueGrey.shade50,
            titleBarColor: Colors.blueGrey.shade200,
            initialMode: EditorMode.view,
            fontList: const ['Roboto', 'Arial', 'Courier'],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 컨트롤러에서 문서의 JSON 표현을 가져옵니다.
          final jsonMap = _controller.document.toJson();
          // jsonEncode를 사용하여 Dart 맵을 사람이 읽기 좋은 형식의 JSON 문자열로 변환합니다.
          final jsonString = jsonEncode(jsonMap, toEncodable: (e) => e.toString());
          // ignore: avoid_print
          print(jsonString);
        },
        tooltip: 'Print JSON',
        child: const Icon(Icons.data_object),
      ),
    );
  }
}
