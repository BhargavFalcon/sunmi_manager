import 'package:get/get.dart';

class InventoryPurchaseOrderController extends GetxController {
  RxString selectedStatus = 'All Status'.obs;
  final List<String> selectedStatusList = ['All Status', 'Created', 'Received'];

  final List<Map<String, String>> supplierItem = [
    {
      'poNo': 'PO-001',
      'supplierName': 'Supplier A',
      'date': '2023-10-01',
      'status': 'Created',
    },
    {
      'poNo': 'PO-002',
      'supplierName': 'Supplier B',
      'date': '2023-10-02',
      'status': 'Created',
    },
    {
      'poNo': 'PO-003',
      'supplierName': 'Supplier C',
      'date': '2023-10-03',
      'status': 'Received',
    },
    {
      'poNo': 'PO-004',
      'supplierName': 'Supplier D',
      'date': '2023-10-04',
      'status': 'Received',
    },
    {
      'poNo': 'PO-005',
      'supplierName': 'Supplier E',
      'date': '2023-10-05',
      'status': 'Received',
    },
    {
      'poNo': 'PO-006',
      'supplierName': 'Supplier F',
      'date': '2023-10-06',
      'status': 'Received',
    },
    {
      'poNo': 'PO-007',
      'supplierName': 'Supplier G',
      'date': '2023-10-07',
      'status': 'Received',
    },
    {
      'poNo': 'PO-008',
      'supplierName': 'Supplier H',
      'date': '2023-10-08',
      'status': 'Received',
    },
  ];


}
