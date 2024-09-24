// lib/screens/cara_bermain.dart
// ignore_for_file: file_names

import 'package:flutter/material.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cara Bermain'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tujuan:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Tujuan permainan ini adalah menebak angka yang benar dalam jumlah percobaan yang terbatas.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Instruksi Permainan:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Pilih jumlah digit (4, 5, atau 6).\n'
                '2. Masukkan tebakan kamu menggunakan keypad.\n'
                '3. Setelah memasukkan tebakan, tekan tombol "Enter".\n'
                '4. Kamu akan menerima umpan balik yang menunjukkan:\n'
                '   - Hijau (🟩): Digit yang benar di posisi yang benar\n'
                '   - Kuning (🟨): Digit yang benar di posisi yang salah\n'
                '   - Abu-abu (⬜): Digit yang salah\n'
                '5. Kamu memiliki jumlah percobaan yang terbatas untuk menebak angka yang benar.\n'
                '6. Jika kamu menebak dengan benar, kamu bisa memasukkan nama untuk menyimpan skor kamu.\n'
                '7. Selamat bermain!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
