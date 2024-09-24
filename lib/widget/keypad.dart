// keypad.dart
import 'package:flutter/material.dart';

typedef KeypadCallback = void Function(String key);

class Keypad extends StatelessWidget {
  final KeypadCallback onKeyPressed;

  const Keypad({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    // Define the keypad layout
    final List<List<String>> keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['⌫', '0', '⏎'],
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () => onKeyPressed(key),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: _getButtonColor(key),
                    ),
                    child: Text(
                      key,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // Optional: Customize button colors based on key type
  Color _getButtonColor(String key) {
    if (key == '⌫') {
      return Colors.redAccent;
    } else if (key == '⏎') {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }
}
