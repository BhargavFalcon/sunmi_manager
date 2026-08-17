import 'package:get/get.dart';
import 'package:managerapp/app/services/printer_service.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';

class PrintServiceController extends GetxController {
  late PrinterService printerService;

  RxBool get isSunmi => printerService.isSunmi;
  RxBool get autoPrintKitchen => printerService.autoPrintKitchen;
  RxInt get kitchenNumberOfCopies => printerService.kitchenCopies;
  RxString get kitchenPaperWidth => printerService.kitchenWidth;
  RxString get receiverPaperWidth => printerService.receiptWidth;
  RxString get orderPaperWidth => printerService.receiptWidth;
  RxBool get autoPrintReceiptWhenPaid => printerService.autoPrintReceipt;
  RxInt get receiptNumberOfCopies => printerService.receiptCopies;

  final connectedPrinters = <Map<String, String>>[].obs;
  RxString get selectedKitchenPrinter => printerService.selectedKitchenPrinter;
  RxString get selectedReceiptPrinter => printerService.selectedReceiptPrinter;

  @override
  void onInit() {
    super.onInit();
    printerService = Get.find<PrinterService>();
    _loadConnectedPrinters();
  }

  void _loadConnectedPrinters() {
    connectedPrinters.clear();
    if (isSunmi.value) {
      connectedPrinters.add({
        'name': TranslationKeys.internalSunmiPrinter.tr,
        'type': 'Internal',
        'address': 'Internal',
      });
    }
    update();
  }

  Future<void> saveSettings({bool showToast = true}) async {
    await printerService.saveGeneralSettings();
    if (showToast) AppToast.showSuccess(TranslationKeys.success.tr);
  }

  void onPrinterSelected(String section, String? printerName) async {
    if (printerName == null) return;
    if (section == 'kitchen') {
      selectedKitchenPrinter.value = printerName;
    } else {
      selectedReceiptPrinter.value = printerName;
    }
    AppToast.showSuccess(
      TranslationKeys.printerSelected.tr.replaceAll('%s', printerName),
    );
  }

  void toggleAutoPrintKitchen() => printerService.toggleAutoPrintKitchen();
  void incrementKitchenCopies() => printerService.incrementKitchenCopies();
  void decrementKitchenCopies() => printerService.decrementKitchenCopies();
  void toggleAutoPrintReceiptWhenPaid() =>
      printerService.toggleAutoPrintReceipt();
  void incrementReceiptCopies() => printerService.incrementReceiptCopies();
  void decrementReceiptCopies() => printerService.decrementReceiptCopies();
}
