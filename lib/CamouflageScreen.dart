import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FolderListScreen.dart';

class CamouflageScreen extends StatefulWidget {
  @override
  _CamouflageScreenState createState() => _CamouflageScreenState();
}

class _CamouflageScreenState extends State<CamouflageScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final String _correctPassword = '1234';

  String displayText = '';
  double num1 = 0;
  double num2 = 0;
  String operator = '';

  void _checkPassword() async {
    if (_passwordController.text == _correctPassword) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FolderListScreen(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sai mật khẩu'),
          content: Text('Mật khẩu không chính xác.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void buttonPressed(String buttonText) {
    if (buttonText == "C") {
      displayText = '';
      num1 = 0;
      num2 = 0;
      operator = '';
    } else if (buttonText == "+" ||
        buttonText == "-" ||
        buttonText == "*" ||
        buttonText == "/") {
      num1 = double.parse(displayText);
      operator = buttonText;
      displayText = '';
    } else if (buttonText == "=") {
      num2 = double.parse(displayText);

      if (operator == "+") {
        displayText = (num1 + num2).toString();
      } else if (operator == "-") {
        displayText = (num1 - num2).toString();
      } else if (operator == "*") {
        displayText = (num1 * num2).toString();
      } else if (operator == "/") {
        displayText = (num1 / num2).toString();
      }

      num1 = 0;
      num2 = 0;
      operator = '';
    } else {
      displayText = displayText + buttonText;
    }

    setState(() {});
  }

  Widget buildButton(String buttonText) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade700,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          onPressed: () => buttonPressed(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade400],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      buildButton("7"),
                      buildButton("8"),
                      buildButton("9"),
                      buildButton("/"),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("4"),
                      buildButton("5"),
                      buildButton("6"),
                      buildButton("*"),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("1"),
                      buildButton("2"),
                      buildButton("3"),
                      buildButton("-"),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("0"),
                      buildButton("C"),
                      buildButton("="),
                      buildButton("+"),
                    ],
                  ),
                ],
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.deepPurple.shade100.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Enter',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
