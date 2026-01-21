import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import 'root_screen.dart';


class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _asAdmin = false;
  bool _isLoading = false;
  bool _isLoginMode = true; 

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_isLoginMode) {
      await auth.login(
        _email,
        _password,
        asAdmin: _asAdmin,
      );
    } else {
      await auth.login(
        _email,
        _password,
        asAdmin: false,
      );
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushReplacementNamed(RootScreen.routeName);

  }

  void _switchMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      if (!_isLoginMode) {
        _asAdmin = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _isLoginMode ? 'Prijava' : 'Registracija';

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DolioApp',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Unesite validan email';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!.trim(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Lozinka'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'Lozinka mora imati bar 4 karaktera';
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value!.trim(),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoginMode)
                      Row(
                        children: [
                          Checkbox(
                            value: _asAdmin,
                            onChanged: (val) {
                              setState(() {
                                _asAdmin = val ?? false;
                              });
                            },
                          ),
                          const Flexible(
                            child: Text('Prijava kao administrator'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: Text(
                                _isLoginMode ? 'Prijavi se' : 'Registruj se',
                              ),
                            ),
                          ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _switchMode,
                      child: Text(
                        _isLoginMode
                            ? 'Nemate nalog? Registrujte se'
                            : 'Već imate nalog? Prijavite se',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
