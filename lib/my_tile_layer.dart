// lib/my_tile_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

// ⭐️ CartoDB Positron No Labels 타일 사용 - 깔끔한 하얀 배경
class MyTileLayer extends StatelessWidget {
  const MyTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    const String whiteMapUrl =
        'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png';
    const String myAppName = 'com.example.jidoapp';

    return TileLayer(
      urlTemplate: whiteMapUrl,
      subdomains: const ['a', 'b', 'c'],
      userAgentPackageName: myAppName,
      backgroundColor: Colors.white,
    );
  }
}