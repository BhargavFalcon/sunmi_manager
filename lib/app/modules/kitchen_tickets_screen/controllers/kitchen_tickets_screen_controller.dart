import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/main.dart';
import 'package:managerapp/app/services/printer_service.dart';
import 'package:managerapp/app/widgets/app_toast.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/mobile_app_modules_model.dart';
import '../../../model/login_models.dart';
import '../../../model/kitchen_ticket_model.dart';
import '../../../utils/printer_helper.dart';
import '../../../services/sunmi_invoice_printer_service.dart';
import '../../../services/escpos_invoice_printer_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class KitchenTicketsScreenController extends GetxController {
  NetworkClient networkClient = NetworkClient();
  RxList<KitchenTicket> tickets = <KitchenTicket>[].obs;
  RxBool isLoading = false.obs;
  RxBool showAccessDialog = false.obs;
  RxInt selectedTabIndex = 0.obs; // 0: In Kitchen, 1: Food is Ready

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  
  RxInt newlyAddedKotId = (-1).obs;
  RxBool isSoundEnabled = true.obs;

  void setNewKotId(int id) {
    if (newlyAddedKotId.value == id) return;
    newlyAddedKotId.value = id;

    // Trigger scroll immediately without waiting for API
    Future.delayed(const Duration(milliseconds: 100), () {
      final index = filteredTickets.indexWhere((t) => t.id == id);
      if (index != -1 && itemScrollController.isAttached) {
        final rowIndex = index ~/ getCrossAxisCount();
        itemScrollController.scrollTo(
          index: rowIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (newlyAddedKotId.value == id) {
        newlyAddedKotId.value = -1;
      }
    });
  }

  int getCrossAxisCount() {
    if (Get.context == null) return 1;
    final width = MediaQuery.of(Get.context!).size.width;
    final orientation = MediaQuery.of(Get.context!).orientation;
    return orientation == Orientation.landscape ? 3 : width > 600 ? 2 : 1;
  }

  @override
  void onInit() {
    super.onInit();
    isSoundEnabled.value =
        box.read(ArgumentConstant.kitchenSoundEnabledKey) ?? _isChef();
    fetchKitchenTickets();
  }

  bool _isChef() {
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData != null && loginModelData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        return loginModel.data?.user?.role?.name?.toLowerCase() == 'chef';
      }
    } catch (_) {}
    return false;
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

  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
    box.write(ArgumentConstant.kitchenSoundEnabledKey, isSoundEnabled.value);
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
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    fetchKitchenTickets();
  }

  Future<void> onPrint(KitchenTicket ticket) async {
    try {
      final printerName = box.read(ArgumentConstant.selectedKitchenPrinterKey);
      final isConnected = await Get.find<PrinterService>()
          .checkPrinterConnectivity(printerName);

      if (!isConnected) {
        AppToast.showError(
          '${TranslationKeys.printerNotConnected.tr}: $printerName',
          title: TranslationKeys.error.tr,
        );
        return;
      }

      final isSunmi = await PrinterHelper.isSunmiDevice();
      if (isSunmi) {
        final sunmiService = SunmiInvoicePrinterService();
        await sunmiService.printKOT(ticket, copies: 1);
      } else {
        final escPosService = EscPosInvoicePrinterService();
        await escPosService.printKOT(ticket, copies: 1);
      }
    } catch (e) {
      log('Manual-print KOT Error: $e');
      AppToast.showError(
        '${TranslationKeys.somethingWentWrong.tr}: $e',
        title: TranslationKeys.error.tr,
      );
    }
  }

  RxMap<String, bool> itemLoadingState = <String, bool>{}.obs;

  Future<void> onItemFoodReady(
    KitchenTicket ticket,
    KitchenTicketItem item,
  ) async {
    final key = '${ticket.id}_${item.id}';
    itemLoadingState[key] = true;
    try {
      final endpoint = ArgumentConstant.updateKotItemStatusEndpoint
          .replaceAll(':kot_id', ticket.id.toString())
          .replaceAll(':item_id', item.id.toString());

      final response = await networkClient.patch(
        endpoint,
        data: {'status': 'ready'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchKitchenTickets();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update item status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      itemLoadingState[key] = false;
    }
  }

  RxMap<String, bool> ticketLoadingState = <String, bool>{}.obs;

  Future<void> onFoodReady(KitchenTicket ticket) async {
    final key = ticket.id.toString();
    ticketLoadingState[key] = true;
    try {
      final endpoint = ArgumentConstant.updateKotStatusEndpoint.replaceAll(
        ':kot_id',
        ticket.id.toString(),
      );

      final response = await networkClient.patch(
        endpoint,
        data: {'status': 'food_ready'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchKitchenTickets();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update KOT status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      ticketLoadingState[key] = false;
    }
  }

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
