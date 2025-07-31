import 'package:get/get.dart';

class InventoryPurchaseOrderController extends GetxController {
  RxString selectedSuppliers = 'All Suppliers'.obs;
  final List<String> selectedSupplierList = [
    'All Suppliers',
    'New Supplier',
    'Test Supplier',
  ];
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
