import 'dart:convert';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import '../../../../main.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/mobile_app_modules_model.dart';
import '../../../model/kitchen_ticket_model.dart';
import '../../../utils/printer_helper.dart';
import '../../../services/sunmi_invoice_printer_service.dart';
import '../../../services/escpos_invoice_printer_service.dart';
import 'package:intl/intl.dart';

class KitchenTicketsScreenController extends GetxController {
  NetworkClient networkClient = NetworkClient();
  RxList<KitchenTicket> tickets = <KitchenTicket>[].obs;
  RxBool isLoading = false.obs;
  RxBool showAccessDialog = false.obs;
  RxInt selectedTabIndex = 0.obs; // 0: In Kitchen, 1: Food is Ready

  @override
  void onInit() {
    super.onInit();
    fetchKitchenTickets();
  }

  @override
  void onReady() {
    super.onReady();
    _checkAndShowDialog();
    box.listenKey(ArgumentConstant.mobileAppModulesKey, (value) {
      _checkAndShowDialog();
    });
  }

  void updateTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  List<KitchenTicket> get inKitchenTickets =>
      tickets.where((t) => t.status == 'in_kitchen').toList();

  List<KitchenTicket> get foodIsReadyTickets =>
      tickets.where((t) => t.status == 'food_ready').toList();

  List<KitchenTicket> get filteredTickets {
    if (selectedTabIndex.value == 0) {
      return inKitchenTickets;
    } else {
      return foodIsReadyTickets;
    }
  }

  int get inKitchenCount => inKitchenTickets.length;
  int get foodIsReadyCount => foodIsReadyTickets.length;

  void _checkAndShowDialog() {
    try {
      final modulesData = box.read(ArgumentConstant.mobileAppModulesKey);
      if (modulesData != null && modulesData is Map<String, dynamic>) {
        final modulesModel = MobileAppModulesModel.fromJson(modulesData);
        final modules = modulesModel.data?.managerAppPermissions ?? [];
        if (!modules.contains('Kitchen Tickets')) {
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

  Future<void> fetchKitchenTickets() async {
    try {
      isLoading.value = true;
      final response = await networkClient.get(ArgumentConstant.kotsEndpoint);
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (_) {}
        }
        if (responseData != null && responseData is Map<String, dynamic>) {
          final model = KitchenTicketResponse.fromJson(responseData);
          if (model.success == true && model.data != null) {
            tickets.assignAll(model.data!);
            isLoading.value = false;
          }
        }
      }
    } catch (e) {
      print('Error fetching kitchen tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    fetchKitchenTickets();
  }

  Future<void> onPrint(KitchenTicket ticket) async {
    try {
      final isSunmi = await PrinterHelper.isSunmiDevice();
      if (isSunmi) {
        final sunmiService = SunmiInvoicePrinterService();
        await sunmiService.printKOT(ticket);
      } else {
        final escPosService = EscPosInvoicePrinterService();
        await escPosService.printKOT(ticket);
      }
    } catch (e) {
      Get.snackbar(
        'Print Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onFoodReady(KitchenTicket ticket) {}

  String formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }
}
