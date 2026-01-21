import 'package:dolio/screens/admin_panel_screen.dart';
import 'package:dolio/screens/auth_screen.dart';
import 'package:dolio/screens/favorites_screen.dart';
import 'package:dolio/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';

import 'screens/root_screen.dart';


void main() {
  runApp(const DolioApp());
}

class DolioApp extends StatelessWidget {
  const DolioApp({super.key});

  ThemeData _buildTheme() {
    const background = Color(0xFF121212); 
    const surface = Color(0xFF1E1E1E);    
    const primaryRed = Color(0xFFE53935); 

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryRed,
      onPrimary: Colors.white,
      secondary: Colors.grey,
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      background: background,
      onBackground: Colors.white,
      surface: surface,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      cardColor: surface,

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryRed,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      iconTheme: const IconThemeData(
        color: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2E),
        selectedColor: primaryRed,
        labelStyle: const TextStyle(color: Colors.white),
        secondarySelectedColor: primaryRed,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DolioApp',
        theme: _buildTheme(),
        home: const RootScreen(),
        routes: {
          RootScreen.routeName: (_) => const RootScreen(),
          AuthScreen.routeName: (_) => const AuthScreen(),
          ProductDetailScreen.routeName: (_) =>
              const ProductDetailScreen(),
          FavoritesScreen.routeName: (_) => const FavoritesScreen(),
          AdminPanelScreen.routeName: (_) =>
              const AdminPanelScreen(),
        },
      ),
    );
  }
}
