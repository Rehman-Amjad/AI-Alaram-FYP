import 'package:flutter/material.dart';

import 'lottie_loader.dart';

class FoodLoading extends StatelessWidget {
  const FoodLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return LottieLoader(lottiePath: "assets/manuLoading.lottie");
  }
}
