import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: SvgPicture.asset('assets/images/logo_mark.svg'),
            ),
            const SizedBox(height: 16),
            Text('BarberShop Medellín', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
