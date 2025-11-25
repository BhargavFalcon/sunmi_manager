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
  bool _isFetching = false;
  Worker? _selectedAreaWorker;

  @override
  void onInit() {
    super.onInit();
    fetchTablesAreas();
    _selectedAreaWorker = ever(selectedAreaIndex, (_) {
      resetScroll();
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh tables every time screen becomes active
    fetchTablesAreas();
  }

  void resetScroll() {
    if (!verticalScrollController.hasClients ||
        !horizontalScrollController.hasClients) {
      return;
    }

    try {
      if (verticalScrollController.hasClients) {
        verticalScrollController.jumpTo(0);
      }
      if (horizontalScrollController.hasClients) {
        horizontalScrollController.jumpTo(0);
      }
    } catch (e) {
      // Controller might be disposed, ignore
      print('Error resetting scroll: $e');
    }
  }

  @override
  void onClose() {
    _selectedAreaWorker?.dispose();
    if (verticalScrollController.hasClients) {
      verticalScrollController.dispose();
    }
    if (horizontalScrollController.hasClients) {
      horizontalScrollController.dispose();
    }
    super.onClose();
  }

  Future<void> fetchTablesAreas() async {
    // Prevent multiple simultaneous API calls
    if (_isFetching) return;

    _isFetching = true;
    isLoading.value = true;
    try {
      final response = await networkClient.get(
        ArgumentConstant.tablesAreasEndpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          tableModel.value = TableModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          update();
        }
      }
    } catch (e) {
      print('Error fetching tables: $e');
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  void navigateToTakeOrderScreen(Tables table) {
    Get.toNamed(
      Routes.TAKE_ORDER_SCREEN,
      arguments: {ArgumentConstant.tableKey: table},
    );
  }
}
