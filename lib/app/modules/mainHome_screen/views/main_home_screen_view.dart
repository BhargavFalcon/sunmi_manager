import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_home_screen_controller.dart';

class MainHomeScreenView extends GetView<MainHomeScreenController> {
  const MainHomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.home, Icons.favorite, Icons.search, Icons.person];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MainHomeScreenView'),
        centerTitle: true,
      ),
      body: Obx(
        () => Center(
          child: Text(
            'Selected Tab: ${controller.selectedIndex.value}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(icons.length, (index) {
                bool isSelected = controller.selectedIndex.value == index;
                return GestureDetector(
                  onTap: () => controller.changeTab(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        color: isSelected ? Colors.brown : Colors.grey,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
