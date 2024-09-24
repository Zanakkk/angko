// main.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:angko/page/HowToPlay.dart';
import 'package:angko/widget/keypad.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Scoreboard.dart';
import 'firebase_options.dart';
import 'models/score_entry.dart';
import 'provider/angko.dart'; // Ensure this path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NumberleApp());
}

class NumberleApp extends StatelessWidget {
  const NumberleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NumberleProvider(),
      child: MaterialApp(
        title: 'Angko',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const NumberleHomePage(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('id', 'ID'), // Tambahkan locale Bahasa Indonesia
        ],
      ),
    );
  }
}

class NumberleHomePage extends StatefulWidget {
  const NumberleHomePage({super.key});

  @override
  _NumberleHomePageState createState() => _NumberleHomePageState();
}

class _NumberleHomePageState extends State<NumberleHomePage> {
  // Helper function to map feedback emojis to colors
  Color _getColor(String feedback) {
    switch (feedback) {
      case '🟩':
        return Colors.green;
      case '🟨':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  void _showLeaderboard(BuildContext context, List<ScoreEntry> highScores) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leaderboard'),
        content: SizedBox(
          width: double.maxFinite,
          child: highScores.isEmpty
              ? const Text('No high scores yet!')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: highScores.length,
                  itemBuilder: (context, index) {
                    final entry = highScores[index];
                    return ListTile(
                      leading: Text('#${index + 1}'),
                      title: Text(entry.username),
                      subtitle: Text(
                        DateFormat("dd/MM/yyyy 'Pukul' HH:mm:ss", 'id_ID')
                            .format(entry.timestamp.toLocal()),
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text('${entry.score} pts'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Function to prompt for username
  void _promptUsername(BuildContext context, NumberleProvider provider) {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter Username'),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            hintText: 'Your Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String username = usernameController.text.trim();
              if (username.isNotEmpty) {
                try {
                  await provider.saveScore(username);
                  Navigator.of(context).pop(); // Close the dialog
                  _showLeaderboard(context, provider.highScores);
                } catch (e) {
                  // Menangani kesalahan jika saveScore gagal
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving score: $e'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username cannot be empty.'),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Angko'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        const HowToPlay()), // Navigasi ke halaman How to Play
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<NumberleProvider>(context, listen: false).resetGame();
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const Scoreboard()),
              );
            },
          ),
        ],
      ),
      body: Consumer<NumberleProvider>(
        builder: (context, provider, child) {
          // Display the digit selection buttons
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      provider.setNumberLength(4);
                      provider
                          .resetGame(); // Reset game after changing the length
                    },
                    child: const Text('4 Digits'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      provider.setNumberLength(5);
                      provider
                          .resetGame(); // Reset game after changing the length
                    },
                    child: const Text('5 Digits'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      provider.setNumberLength(6);
                      provider
                          .resetGame(); // Reset game after changing the length
                    },
                    child: const Text('6 Digits'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Display the grid of guesses
              SizedBox(
                height: 320,
                width: (60 * provider.numberLength)
                    .toDouble(), // Lebar diatur menjadi 40 dikali panjang digit
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: provider
                            .numberLength, // Menggunakan jumlah dinamis berdasarkan panjang
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: provider.maxAttempts * provider.numberLength,
                      itemBuilder: (context, index) {
                        int attempt = index ~/ provider.numberLength;
                        int digitIndex = index % provider.numberLength;

                        if (attempt < provider.guesses.length) {
                          String guess = provider.guesses[attempt];
                          List<String> feedback = provider.feedbacks[attempt];

                          String digit = guess[digitIndex];
                          String fb = feedback[digitIndex];
                          Color color = _getColor(fb);

                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              digit,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        } else if (attempt == provider.guesses.length) {
                          // Current input attempt
                          String digit =
                              digitIndex < provider.currentInput.length
                                  ? provider.currentInput[digitIndex]
                                  : '';
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: digit.isNotEmpty
                                  ? Colors.white
                                  : Colors.grey[200],
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              digit,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: digit.isNotEmpty
                                    ? Colors.black
                                    : Colors.transparent,
                              ),
                            ),
                          );
                        } else {
                          // Empty cells
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 240,
                child: Keypad(
                  onKeyPressed: (key) {
                    provider.handleKeyPress(key);

                    // After handling key press, check for win or loss
                    if (key == '⏎' && provider.guesses.isNotEmpty) {
                      String lastGuess = provider.guesses.last;
                      if (lastGuess == provider.targetNumber) {
                        // Show win dialog
                        _promptUsername(context, provider);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Congratulations!'),
                            content: Text(
                                'You guessed the number $lastGuess correctly!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  provider.resetGame();
                                },
                                child: const Text('Play Again'),
                              ),
                            ],
                          ),
                        );
                      } else if (provider.guesses.length >=
                          provider.maxAttempts) {
                        // Show loss dialog
                        _promptUsername(context, provider);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Game Over'),
                            content: Text(
                                'The correct number was ${provider.targetNumber}.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  provider.resetGame();
                                },
                                child: const Text('Play Again'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
