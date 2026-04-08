import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crypto/crypto.dart';
import 'package:animate_do/animate_do.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/encryption_helper.dart';
import 'notes_list_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _pinController = TextEditingController();
  bool _isBiometricSupported = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Initialize encryption first
    await EncryptionHelper.init();
    if (!mounted) return;

    final canCheck = await _biometricService.canCheckBiometrics();
    if (!mounted) return;
    setState(() => _isBiometricSupported = canCheck);

    if (canCheck) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      if (!mounted) return;
      _navigateToNotes();
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    final storedHash = await SecureStorageService.loadPinHash();

    if (!mounted) return;

    if (storedHash == null) {
      // First time setup - prompt for PIN creation
      _setupPin();
      setState(() => _isLoading = false);
      return;
    }

    final inputHash = sha256
        .convert(utf8.encode(_pinController.text))
        .toString();
    if (inputHash == storedHash) {
      _navigateToNotes();
    } else {
      _showErrorSnackBar('Incorrect PIN. Please try again.');
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _setupPin() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Setup Secure PIN',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Enter 4-6 digit PIN',
            hintText: 'e.g. 1234',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_pinController.text.length < 4) {
                _showErrorSnackBar("PIN must be at least 4 digits");
                return;
              }
              Navigator.pop(context, _pinController.text);
            },
            child: const Text('SAVE PIN'),
          ),
        ],
      ),
    );

    final hash = sha256.convert(utf8.encode(_pinController.text)).toString();
    await SecureStorageService.savePinHash(hash);
    _navigateToNotes();
  }

  void _navigateToNotes() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotesListScreen()),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Secure Notes',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Your thoughts, protected with maximum security.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              if (_isBiometricSupported) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _authenticateWithBiometrics,
                      icon: const Icon(Icons.fingerprint, size: 28),
                      label: const Text('Unlock with Biometrics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR USE PIN",
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: 'PIN',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 8,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    counterText: "",
                  ),
                  onSubmitted: (_) => _verifyPin(),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 900),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Unlock Access'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
