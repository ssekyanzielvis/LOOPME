import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'; // Add emoji picker

class RepeatedTextApp extends StatelessWidget {
  const RepeatedTextApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LOOPME',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _repeatController = TextEditingController();
  String? selectedShape;
  String repeatedText = '';
  final List<String> shapes = ['List', 'Grid', 'Circle'];
  bool isEmojiPickerVisible = false;

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to copy!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void toggleEmojiPicker() {
    setState(() {
      isEmojiPickerVisible = !isEmojiPickerVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOOPME'),
        centerTitle: true,
        elevation: 4.0,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            labelText: 'Text to Repeat (supports emojis 😊)',
                            labelStyle: const TextStyle(color: Colors.indigo),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo),
                            ),
                            filled: true,
                            fillColor: Colors.indigo[50],
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
                            labelStyle: const TextStyle(color: Colors.indigo),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo),
                            ),
                            filled: true,
                            fillColor: Colors.indigo[50],
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: selectedShape,
                          decoration: InputDecoration(
                            labelText: 'Choose Display Shape',
                            labelStyle: const TextStyle(color: Colors.indigo),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.indigo[50],
                          ),
                          items: shapes
                              .map(
                                (shape) => DropdownMenuItem(
                                  value: shape,
                                  child: Text(shape),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedShape = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: generateText,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Generate Text',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: copyToClipboard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Copy to Clipboard',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (repeatedText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.indigo, width: 1),
                            ),
                            child: Text(
                              repeatedText,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                            ),
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
    );
  }
}
