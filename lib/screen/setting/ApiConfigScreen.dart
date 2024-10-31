import 'package:carabaobillingapps/screen/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/color_constant.dart';
import '../../constant/data_constant.dart';
import '../../constant/url_constant.dart';
import '../../helper/BottomSheetFeedback.dart';

class ApiConfigScreen extends StatefulWidget {
  final bool isFirstInstall;
  final VoidCallback? onConfigured;

  const ApiConfigScreen({
    Key? key,
    this.isFirstInstall = false,
    this.onConfigured,
  }) : super(key: key);

  @override
  State<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen> {
  final TextEditingController _endpointController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentEndpoint();
  }

  Future<void> _loadCurrentEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final endpoint = prefs.getString(ConstantData.api_endpoint);
    if (endpoint != null) {
      setState(() {
        _endpointController.text = endpoint;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEndpoint() async {
    String endpoint = _endpointController.text.trim();

    // Basic validation
    if (endpoint.isEmpty) {
      BottomSheetFeedback.showError(
          context, "Validation Error", "API endpoint cannot be empty");
      return;
    }

    try {
      final uri = Uri.parse(endpoint);
      if (!uri.isScheme('http') && !uri.isScheme('https')) {
        BottomSheetFeedback.showError(context, "Validation Error",
            "Please enter a valid HTTP or HTTPS URL");
        return;
      }
    } catch (e) {
      BottomSheetFeedback.showError(
          context, "Validation Error", "Please enter a valid URL");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ConstantData.api_endpoint, endpoint);
      UrlConstant.setBaseUrl(endpoint);

      BottomSheetFeedback.showSuccess(
          context, "Success", "API endpoint updated successfully");

      if (widget.isFirstInstall) {
        if (widget.onConfigured != null) {
          widget.onConfigured?.call();
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      BottomSheetFeedback.showError(
          context, "Error", "Failed to save API endpoint");
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFirstInstall
          ? null
          : AppBar(
              title: Text('API Configuration'),
            ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isFirstInstall) ...[
                      SizedBox(height: 50.h),
                      Text(
                        'Selamat datang!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: ColorConstant.primary,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Setup API endpoint sebelum melanjutkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          color: ColorConstant.subtext,
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                    Text(
                      'API Endpoint',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorConstant.titletext,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: _endpointController,
                      decoration: InputDecoration(
                        hintText: 'https://api.example.com',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 15.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveEndpoint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstant.primary,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                        ),
                        child: Text(
                          'Set API Endpoint',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
