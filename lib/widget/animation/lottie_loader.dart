import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieLoader extends StatelessWidget {
  final String lottiePath;
  const LottieLoader({super.key, required this.lottiePath});

  @override
  Widget build(BuildContext context) {
    return DotLottieLoader.fromAsset(lottiePath,
        frameBuilder: (ctx, dotLottie) {
      if (dotLottie != null) {
        return Lottie.memory(dotLottie.animations.values.single,
            imageProviderFactory: (asset) {
          return MemoryImage(dotLottie.images[asset.fileName]!);
        });
      } else {
        return Container();
      }
    });
  }
}
