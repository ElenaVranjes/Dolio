import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/favorites_screen.dart';
import '../screens/admin_panel_screen.dart';
import '../screens/admin_orders_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  /// Koji korisnik je trenutno učitan u poljima –
  /// koristimo da znamo kad treba da promenimo vrednosti
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isAuth) {
      // Nema ulogovanog korisnika → očisti polja
      _lastUserId = null;
      _fullNameController.text = '';
      _addressController.text = '';
      _phoneController.text = '';
    } else if (auth.userId != _lastUserId) {
      // Promenio se korisnik → napuni polja njegovim podacima
      _lastUserId = auth.userId;
      _fullNameController.text = auth.fullName;
      _addressController.text = auth.address;
      _phoneController.text = auth.phone;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    await Provider.of<AuthProvider>(context, listen: false).updateProfile(
      fullName: _fullNameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil je uspešno sačuvan.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Nije ulogovan korisnik → ekran sa dugmetom za prijavu
    if (!auth.isAuth) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Za pristup profilu, omiljenim proizvodima i istoriji narudžbina potrebno je da se prijavite.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AuthScreen.routeName);
                },
                child: const Text('Prijava / Registracija'),
              ),
            ],
          ),
        ),
      );
    }

    // Ulogovan korisnik
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zdravo, ${auth.displayName}!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Ime i prezime',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Unesite ime i prezime';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresa isporuke',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Kontakt telefon',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Sačuvaj profil'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Omiljeni proizvodi'),
            onTap: () {
              Navigator.of(context).pushNamed(FavoritesScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Istorija narudžbina'),
            subtitle: const Text('Pregled prethodnih narudžbina.'),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(OrderHistoryScreen.routeName);
            },
          ),
          const Divider(),
          if (auth.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Administratorski panel'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AdminPanelScreen.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Sve narudžbine'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AdminOrdersScreen.routeName);
              },
            ),
            const Divider(),
          ],
        ],
      ),
    );
  }
}
