import 'package:carabaobillingapps/screen/setting/PinEntryScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _currentPinControllers =
      List.generate(4, (_) => TextEditingController());
  final _newPinControllers = List.generate(4, (_) => TextEditingController());
  final _confirmNewPinControllers =
      List.generate(4, (_) => TextEditingController());
  final _currentPinFocusNodes = List.generate(4, (_) => FocusNode());
  final _newPinFocusNodes = List.generate(4, (_) => FocusNode());
  final _confirmNewPinFocusNodes = List.generate(4, (_) => FocusNode());

  String _storedPin = '0000'; // Default PIN
  final String _secretPin = '5381'; // Default PIN

  @override
  void dispose() {
    for (var controller in _currentPinControllers) {
      controller.dispose();
    }
    for (var focusNode in _currentPinFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _newPinControllers) {
      controller.dispose();
    }
    for (var focusNode in _newPinFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _confirmNewPinControllers) {
      controller.dispose();
    }
    for (var focusNode in _confirmNewPinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStoredPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pin = prefs.getString('user_pin');
    if (pin == null) {
      // If no PIN is stored, save the default PIN
      await prefs.setString('user_pin', _storedPin);
    } else {
      _storedPin = pin;
    }
  }

  Future<void> _onSubmit() async {
    final currentPin =
        _currentPinControllers.map((controller) => controller.text).join();
    if (currentPin == _secretPin) {
      final newPin =
          _newPinControllers.map((controller) => controller.text).join();
      final confirmNewPin =
          _confirmNewPinControllers.map((controller) => controller.text).join();

      if (newPin != confirmNewPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New PINs do not match')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin', newPin);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN changed successfully')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PinEntryScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Secret Pin Not Valid')),
      );
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStoredPin(); // Load the stored PIN when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change PIN'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Secret PIN'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.only(left: 10.w),
                    width: 50,
                    child: TextField(
                      controller: _currentPinControllers[index],
                      focusNode: _currentPinFocusNodes[index],
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
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 3) {
                            FocusScope.of(context)
                                .requestFocus(_currentPinFocusNodes[index + 1]);
                          }
                        } else if (index > 0) {
                          FocusScope.of(context)
                              .requestFocus(_currentPinFocusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text('New PIN'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.only(left: 10.w),
                    width: 50,
                    child: TextField(
                      controller: _newPinControllers[index],
                      focusNode: _newPinFocusNodes[index],
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      textInputAction: index == 3
                          ? TextInputAction.next
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
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 3) {
                            FocusScope.of(context)
                                .requestFocus(_newPinFocusNodes[index + 1]);
                          }
                        } else if (index > 0) {
                          FocusScope.of(context)
                              .requestFocus(_newPinFocusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text('Confirm New PIN'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.only(left: 10.w),
                    width: 50,
                    child: TextField(
                      controller: _confirmNewPinControllers[index],
                      focusNode: _confirmNewPinFocusNodes[index],
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
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 3) {
                            FocusScope.of(context).requestFocus(
                                _confirmNewPinFocusNodes[index + 1]);
                          }
                        } else if (index > 0) {
                          FocusScope.of(context).requestFocus(
                              _confirmNewPinFocusNodes[index - 1]);
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
    );
  }
}
