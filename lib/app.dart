import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'piano_game.dart';

void main() {
  runApp(const RepeatedTextApp());
}

class RepeatedTextApp extends StatefulWidget {
  const RepeatedTextApp({Key? key}) : super(key: key);

  @override
  _RepeatedTextAppState createState() => _RepeatedTextAppState();
}

class _RepeatedTextAppState extends State<RepeatedTextApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LOOPME',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.black87,
      ),
      themeMode: _themeMode,
      home: HomePage(toggleTheme: toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomePage({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _repeatController = TextEditingController();
  String? selectedShape;
  String repeatedText = '';
  bool isEmojiPickerVisible = false;
  final List<String> shapes = [
    'List',
    'Grid',
    'Circle',
    ...List.generate(26, (index) => String.fromCharCode(65 + index))
  ];

  void generateText() {
    String text = _textController.text;
    int repetitions = int.tryParse(_repeatController.text) ?? 0;

    if (text.isEmpty || repetitions <= 0 || selectedShape == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide all inputs!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<String> repeatedList = List.generate(repetitions, (_) => text);

    setState(() {
      if (selectedShape == 'List') {
        repeatedText = repeatedList.join('\n');
      } else if (selectedShape == 'Grid') {
        repeatedText = repeatedList.join(' ');
      } else if (selectedShape == 'Circle') {
        repeatedText = repeatedList.join(' ○ ');
      } else {
        repeatedText = repeatedList.join(' $selectedShape ');
      }
    });
  }

  void copyToClipboard() {
    if (repeatedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: repeatedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void toggleEmojiPicker() {
    setState(() {
      isEmojiPickerVisible = !isEmojiPickerVisible;
    });
  }

  void navigateToPianoGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PianoGame()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOOPME'),
        centerTitle: true,
        elevation: 4.0,
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.wb_sunny
                : Icons.nights_stay),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter the details below:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            labelText: 'Text to Repeat',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.emoji_emotions),
                              onPressed: toggleEmojiPicker,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _repeatController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Number of Repetitions',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: selectedShape,
                          decoration: InputDecoration(
                            labelText: 'Choose Display Shape',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          items: shapes
                              .map((shape) => DropdownMenuItem(
                                    value: shape,
                                    child: Text(shape),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedShape = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                  onPressed: generateText,
                                  child: const Text('Generate Text')),
                              ElevatedButton(
                                  onPressed: copyToClipboard,
                                  child: const Text('Copy to Clipboard')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (repeatedText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all()),
                            child: Text(repeatedText),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isEmojiPickerVisible)
            EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _textController.text += emoji.emoji;
              },
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            onTap: navigateToPianoGame,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note),
                SizedBox(width: 10),
                Text(
                  'Play Piano',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
