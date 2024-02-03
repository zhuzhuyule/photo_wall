import 'package:flutter/material.dart';

class FavoriteList extends StatelessWidget {
  const FavoriteList({
    super.key,
    required this.isOpen,
  });

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastLinearToSlowEaseIn,
      width: isOpen ? 300 : 0,
      height: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.black26, // 设置左边线的颜色
            width: 1.0, // 设置左边线的宽度
          ),
        ),
      ),
      child: Container(child: const Text('')),
    );
  }
}
