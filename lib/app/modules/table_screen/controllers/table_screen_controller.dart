import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/api_constants.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/tableModel.dart';
import '../../../routes/app_pages.dart';

class TableScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final tableModel = Rx<TableModel?>(null);
  final selectedAreaIndex = 0.obs;
  final verticalScrollController = ScrollController();
  final horizontalScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchTablesAreas();
    selectedAreaIndex.listen((_) {
      resetScroll();
    });
  }

  void resetScroll() {
    if (verticalScrollController.hasClients) {
      verticalScrollController.jumpTo(0);
    }
    if (horizontalScrollController.hasClients) {
      horizontalScrollController.jumpTo(0);
    }
  }

  @override
  void onClose() {
    verticalScrollController.dispose();
    horizontalScrollController.dispose();
    super.onClose();
  }

  Future<void> fetchTablesAreas() async {
    isLoading.value = true;
    final response = await networkClient.get(
      ArgumentConstant.tablesAreasEndpoint,
    );
    isLoading.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data != null && response.data is Map<String, dynamic>) {
        tableModel.value = TableModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        update();
      }
    }
  }

  void navigateToTakeOrderScreen(Tables table) {
    Get.toNamed(
      Routes.TAKE_ORDER_SCREEN,
      arguments: {ArgumentConstant.tableKey: table},
    );
  }
}
