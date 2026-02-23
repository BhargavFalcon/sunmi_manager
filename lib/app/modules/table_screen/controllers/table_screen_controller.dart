import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/api_constants.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/tableModel.dart';
import '../../../model/MobileAppModulesModel.dart';
import '../../../../main.dart';

class TableScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final isNavigatingToOrder = false.obs;
  final showAccessDialog = false.obs;
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
    _checkAndShowDialog();
    box.listenKey(ArgumentConstant.mobileAppModulesKey, (value) {
      _checkAndShowDialog();
    });
  }

  void _checkAndShowDialog() {
    try {
      final modulesData = box.read(ArgumentConstant.mobileAppModulesKey);
      if (modulesData != null && modulesData is Map<String, dynamic>) {
        final modulesModel = MobileAppModulesModel.fromJson(modulesData);
        final modules = modulesModel.data?.managerAppPermissions ?? [];
        if (!modules.contains('POS')) {
          Future.delayed(const Duration(milliseconds: 100), () {
            showAccessDialog.value = true;
          });
        } else {
          showAccessDialog.value = false;
        }
      }
    } catch (e) {
      // Handle error silently
    }
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
    } catch (e) {}
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
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }
}
