import 'package:flutter/material.dart';
import 'package:jidoapp/widgets/plane_loading_logo.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: PlaneLoadingLogo(size: 200),
      ),
    );
  }
}
