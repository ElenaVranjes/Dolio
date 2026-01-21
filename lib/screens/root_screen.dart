import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';

import '../screens/cart_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/products_overview_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/badge.dart';
import 'auth_screen.dart';

class RootScreen extends StatefulWidget {
  static const routeName = '/root';

  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  String? _productsInitialCategory;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 1) {
        _productsInitialCategory = null;
      }
    });
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'DolioApp';
      case 1:
        return 'Proizvodi';
      case 2:
        return 'Korpa';
      case 3:
        return 'Profil';
      default:
        return 'DolioApp';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          onCategorySelected: (category) {
            setState(() {
              _selectedIndex = 1; 
              _productsInitialCategory = category;
            });
          },
        );
      case 1:
        return ProductsOverviewScreen(
          initialCategory: _productsInitialCategory,
        );
      case 2:
        return const CartScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (_selectedIndex != 2)
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                  _productsInitialCategory = null;
                });
              },
              icon: CartBadge(
                value: cart.itemCount.toString(),
                child: const Icon(Icons.shopping_cart),
              ),
            ),
          IconButton(
            onPressed: () {
              if (auth.isAuth) {
                Provider.of<CartProvider>(context, listen: false).clear();
                Provider.of<ProductsProvider>(context, listen: false)
                    .clearFavorites();
                auth.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Uspešna odjava.'),
                  ),
                );
              } else {
                Navigator.of(context).pushNamed(AuthScreen.routeName);
              }
            },
            icon: Icon(
              auth.isAuth ? Icons.logout : Icons.login,
            ),
            tooltip: auth.isAuth ? 'Odjava' : 'Prijava',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Početna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Proizvodi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Korpa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
