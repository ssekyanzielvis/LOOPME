import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class PianoGame extends StatefulWidget {
  const PianoGame({Key? key}) : super(key: key);

  @override
  State<PianoGame> createState() => _PianoGameState();
}

class _PianoGameState extends State<PianoGame> {
  final List<String> notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  final List<String> additionalNotes = [
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q'
  ];
  final List<String> bottomBarNotes = [
    'R', 'S', 'T', 'U', 'V', 'W', 'X' // Notes for the bottom bar
  ];

  final AudioPlayer audioPlayer = AudioPlayer();
  String? currentTargetNote;
  int score = 0;
  bool isPlaying = true;
  int timeLeft = 100;
  Timer? _timer;

  void playSound(String note) async {
    try {
      await audioPlayer.setSource(AssetSource('sounds/$note.mp3'));
      await audioPlayer.resume();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void generateNewTarget() {
    final random = Random();
    setState(() {
      currentTargetNote = notes[random.nextInt(notes.length)];
    });
  }

  void handleTap(String note) {
    if (!isPlaying) return;
    playSound(note);
    setState(() {
      if (note == currentTargetNote) {
        score += 4;
      } else {
        score -= 4;
      }
      generateNewTarget();
    });
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          endGame();
        }
      });
    });
  }

  void pauseGame() {
    setState(() => isPlaying = false);
    _timer?.cancel();
  }

  void resumeGame() {
    setState(() => isPlaying = true);
    startTimer();
  }

  void resetGame() {
    setState(() {
      score = 0;
      timeLeft = 100;
      isPlaying = true;
    });
    startTimer();
    generateNewTarget();
  }

  void endGame() {
    setState(() => isPlaying = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(getScoreMessage()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String getScoreMessage() {
    if (score >= 100) return "You have maximized!";
    if (score >= 80) return "That's excellent!";
    if (score >= 65) return "That's good!";
    if (score >= 50) return "It's a fair score.";
    if (score >= 35) return "You're too ordinary.";
    if (score >= 15) return "Aim for a better score.";
    return "You're a failure.";
  }

  @override
  void initState() {
    super.initState();
    generateNewTarget();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  Widget buildPianoButton(
      String note, Color color, double width, double height) {
    return GestureDetector(
      onTap: () => handleTap(note),
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 2,
                offset: const Offset(0, 3))
          ],
        ),
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            note,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color == Colors.black ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('🎵 Piano Game'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeData.brightness == Brightness.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Score, Target Note, Timer
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Piano Game',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Score: $score",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Target Note: $currentTargetNote",
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Time Left: $timeLeft seconds",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent),
                    ),
                  ],
                ),
              ),
            ),

            // Game Buttons
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: generateNewTarget,
                      child: const Text('🎯 New Target Note')),
                  const SizedBox(height: 15),
                  ElevatedButton(
                      onPressed: resetGame, child: const Text('🔄 Reset Game')),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: isPlaying ? pauseGame : resumeGame,
                    child: Text(isPlaying ? '⏸ Pause Game' : '▶ Resume Game'),
                  ),
                ],
              ),
            ),

            // Scrollable Piano Keys (White and Additional)
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: notes
                              .map((note) => buildPianoButton(
                                  note,
                                  Colors.white,
                                  screenWidth * 0.12,
                                  screenHeight * 0.15))
                              .toList()),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: additionalNotes
                              .map((note) => buildPianoButton(
                                  note,
                                  Colors.black,
                                  screenWidth * 0.12,
                                  screenHeight * 0.12))
                              .toList()),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar with R, S, T, U, V, W, X Keys
            Container(
              height: screenHeight * 0.15, // 15% of screen height
              color: Colors.black.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: bottomBarNotes
                    .map((note) => buildPianoButton(
                        note,
                        Colors.black,
                        screenWidth * 0.12, // 12% of screen width
                        screenHeight * 0.12)) // 12% of screen height
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
