import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blocs/location/location_bloc.dart';
import 'blocs/shop/shop_bloc.dart';
import 'repositories/shop_repository.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final shopRepository = ShopRepository();

    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: shopRepository)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => LocationBloc()),
          BlocProvider(
            create: (context) => ShopBloc(shopRepository: shopRepository),
          ),
        ],
        child: MaterialApp(
          title: 'ShopLocator',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF0047AB),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0047AB),
              primary: const Color(0xFF0047AB),
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.outfitTextTheme(),
          ),
          home: const WelcomeScreen(),
        ),
      ),
    );
  }
}
