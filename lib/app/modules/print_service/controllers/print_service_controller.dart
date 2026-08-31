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
  RxBool get autoPrintReceiptWhenPaid => printerService.autoPrintReceipt;
  RxInt get receiptNumberOfCopies => printerService.receiptCopies;

  @override
  void onInit() {
    super.onInit();
    printerService = Get.find<PrinterService>();
  }

  Future<void> saveSettings({bool showToast = true}) async {
    await printerService.saveGeneralSettings();
    if (showToast) AppToast.showSuccess(TranslationKeys.success.tr);
  }

  void toggleAutoPrintKitchen() => printerService.toggleAutoPrintKitchen();
  void incrementKitchenCopies() => printerService.incrementKitchenCopies();
  void decrementKitchenCopies() => printerService.decrementKitchenCopies();
  void toggleAutoPrintReceiptWhenPaid() =>
      printerService.toggleAutoPrintReceipt();
  void incrementReceiptCopies() => printerService.incrementReceiptCopies();
  void decrementReceiptCopies() => printerService.decrementReceiptCopies();
}
