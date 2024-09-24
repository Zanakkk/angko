// lib/screens/scoreboard.dart
// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/angko.dart';
import '../models/score_entry.dart';

class Scoreboard extends StatefulWidget {
  const Scoreboard({super.key});

  @override
  _ScoreboardState createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  int? _selectedDigitLength; // Untuk menyimpan pilihan panjang digit

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NumberleProvider>(context);
    List<ScoreEntry> filteredScores;

    // Filter berdasarkan panjang digit jika ada pilihan
    if (_selectedDigitLength != null) {
      filteredScores = provider.highScores
          .where((entry) => entry.digitLength == _selectedDigitLength)
          .toList();
    } else {
      filteredScores = provider.highScores; // Semua skor jika tidak ada filter
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (int value) {
              setState(() {
                _selectedDigitLength = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(value: 4, child: Text('4 Digits')),
              const PopupMenuItem(value: 5, child: Text('5 Digits')),
              const PopupMenuItem(value: 6, child: Text('6 Digits')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: filteredScores.isEmpty
          ? const Center(
              child: Text(
                'No high scores yet!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: filteredScores.length,
              itemBuilder: (context, index) {
                final ScoreEntry entry = filteredScores[index];
                return ListTile(
                  leading: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  title: Text(
                    entry.username,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat("dd/MM/yyyy 'Pukul' HH:mm:ss", 'id_ID')
                            .format(entry.timestamp.toLocal()),
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Input Count: ${entry.inputCount}', // Menampilkan jumlah input
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Elapsed Time: ${entry.elapsedTime} seconds', // Menampilkan waktu yang dihabiskan
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${entry.score} pts',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}
