import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _regFullNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regFullNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Unesite email adresu';
    }
    final emailRegex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email adrese nije ispravan';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Unesite lozinku';
    }
    if (value.length < 8) {
      return 'Lozinka mora imati najmanje 8 karaktera';
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);

    if (!hasLetter || !hasDigit) {
      return 'Lozinka mora sadržati slova i brojeve';
    }

    return null;
  }

  Future<void> _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      await auth.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // zatvori ekran posle uspešne prijave
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri prijavi: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final password = _regPasswordController.text;
    final confirm = _regConfirmPasswordController.text;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lozinke se ne poklapaju.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await auth.register(
        email: _regEmailController.text.trim(),
        password: password,
        fullName: _regFullNameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // zatvori ekran posle registracije
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri registraciji: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prijava i registracija'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Prijava'),
              Tab(text: 'Registracija'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                // PRIJAVA
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _loginEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _loginPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Lozinka',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Unesite lozinku';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _submitLogin,
                            child: const Text('Prijavi se'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // REGISTRACIJA
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _registerFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _regFullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Ime i prezime',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Unesite ime i prezime';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _regEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _regPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Lozinka',
                            helperText:
                                'Najmanje 8 karaktera, mora sadržati slova i brojeve.',
                          ),
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller:
                              _regConfirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Potvrda lozinke',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Potvrdite lozinku';
                            }
                            if (value !=
                                _regPasswordController.text) {
                              return 'Lozinke se ne poklapaju';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _submitRegister,
                            child: const Text('Registruj se'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
