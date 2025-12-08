import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/tableModel.dart';
import '../../../model/getorderModel.dart' as orderModel;
import '../../../routes/app_pages.dart';

class TableScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final isNavigatingToOrder = false.obs;
  final isDeletingOrder = false.obs;
  final isChangingTable = false.obs;
  final isProcessingPayment = false.obs;
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

  Future<void> navigateToTakeOrderScreen(Tables table) async {
    // Check if table has active order
    if (table.activeOrder != null && table.activeOrder!.uuid != null) {
      isNavigatingToOrder.value = true;
      try {
        // Fetch order details without showing loader
        final orderUuid = table.activeOrder!.uuid!;
        final endpoint = ArgumentConstant.getOrderEndpoint.replaceAll(
          ':order_uuid',
          orderUuid,
        );
        final response = await networkClient.get(endpoint);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data != null && response.data is Map<String, dynamic>) {
            final order = orderModel.GetOrderModel.fromJson(
              response.data as Map<String, dynamic>,
            );
            // Navigate with both table and order
            Get.toNamed(
              Routes.TAKE_ORDER_SCREEN,
              arguments: {
                ArgumentConstant.tableKey: table,
                ArgumentConstant.orderKey: order,
              },
            );
            return;
          }
        }
        // If API call fails, navigate without order
        Get.toNamed(
          Routes.TAKE_ORDER_SCREEN,
          arguments: {ArgumentConstant.tableKey: table},
        );
      } catch (e) {
        print('Error fetching order: $e');
        safeGetSnackbar(
          'Error',
          'Failed to load order details',
          snackPosition: SnackPosition.TOP,
        );
        // Navigate without order on error
        Get.toNamed(
          Routes.TAKE_ORDER_SCREEN,
          arguments: {ArgumentConstant.tableKey: table},
        );
      } finally {
        isNavigatingToOrder.value = false;
      }
    } else {
      // No active order, navigate normally
      Get.toNamed(
        Routes.TAKE_ORDER_SCREEN,
        arguments: {ArgumentConstant.tableKey: table},
      );
    }
  }

  Future<void> deleteOrder(Tables table) async {
    if (table.activeOrder == null || table.activeOrder!.uuid == null) {
      safeGetSnackbar(
        'Error',
        'No active order found to delete',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isDeletingOrder.value = true;
    try {
      final orderUuid = table.activeOrder!.uuid!;
      final endpoint = ArgumentConstant.deleteOrderEndpoint.replaceAll(
        ':order_uuid',
        orderUuid,
      );

      final response = await networkClient.delete(endpoint);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        safeGetSnackbar(
          'Success',
          'Order deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh tables to reflect the deletion
        await fetchTablesAreas();
      } else {
        safeGetSnackbar(
          'Error',
          'Failed to delete order',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting order: $e');
      String errorMessage = 'Failed to delete order';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      safeGetSnackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeletingOrder.value = false;
    }
  }

  Future<void> changeOrderTable(Tables currentTable, int newTableId) async {
    if (currentTable.activeOrder == null ||
        currentTable.activeOrder!.uuid == null) {
      safeGetSnackbar(
        'Error',
        'No active order found to change table',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isChangingTable.value = true;
    try {
      final orderUuid = currentTable.activeOrder!.uuid!;
      final endpoint = ArgumentConstant.changeOrderTableEndpoint.replaceAll(
        ':order_uuid',
        orderUuid,
      );

      final requestBody = {'table_id': newTableId};

      final response = await networkClient.patch(endpoint, data: requestBody);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        safeGetSnackbar(
          'Success',
          'Table changed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh tables to reflect the change
        await fetchTablesAreas();
      } else {
        safeGetSnackbar(
          'Error',
          'Failed to change table',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error changing table: $e');
      String errorMessage = 'Failed to change table';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      safeGetSnackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isChangingTable.value = false;
    }
  }

  Future<void> createPayment(Tables table) async {
    if (table.activeOrder == null || table.activeOrder!.uuid == null) {
      safeGetSnackbar(
        'Error',
        'No active order found to process payment',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final orderUuid = table.activeOrder!.uuid!;
    final orderTotal = table.activeOrder!.total ?? 0.0;

    if (orderTotal <= 0) {
      safeGetSnackbar(
        'Error',
        'Order total is invalid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isProcessingPayment.value = true;
    try {
      final paymentBody = {
        'order_id': orderUuid,
        'amount': orderTotal.toStringAsFixed(2),
        'payment_method': 'cash',
      };

      final response = await networkClient.post(
        ArgumentConstant.paymentsEndpoint,
        data: paymentBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        safeGetSnackbar(
          'Success',
          'Payment processed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh tables to reflect the payment
        await fetchTablesAreas();
      } else {
        safeGetSnackbar(
          'Error',
          'Failed to process payment',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error processing payment: $e');
      String errorMessage = 'Failed to process payment';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      safeGetSnackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessingPayment.value = false;
    }
  }
}
