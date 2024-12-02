import 'package:carabaobillingapps/screen/setting/ListSetting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BottomNavigationScreen.dart';
import 'ChangePinScreen.dart'; // Import the change PIN screen

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final _pinControllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  String? _storedPin; // Store the PIN from SharedPreferences

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStoredPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storedPin = prefs.getString('user_pin');
  }

  @override
  void initState() {
    super.initState();
    _loadStoredPin(); // Load the stored PIN when the screen initializes
  }

  void _onSubmit() {
    final enteredPin =
        _pinControllers.map((controller) => controller.text).join();
    if (enteredPin == _storedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ListSetting(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Enter PIN'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePinScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter PIN',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        margin: EdgeInsets.only(left: 10.w),
                        width: 50,
                        child: TextField(
                          controller: _pinControllers[index],
                          focusNode: _focusNodes[index],
                          autofocus: index == 0,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          textInputAction: index == 3
                              ? TextInputAction.done
                              : TextInputAction.next,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (index < 3) {
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index + 1]);
                              } else {
                                FocusScope.of(context)
                                    .unfocus(); // Remove focus from the last field
                                _onSubmit();
                              }
                            } else if (index > 0) {
                              FocusScope.of(context)
                                  .requestFocus(_focusNodes[index - 1]);
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationScreen(
                        defaultMenuIndex: 2,
                      )));
          return false;
        });
  }
}
