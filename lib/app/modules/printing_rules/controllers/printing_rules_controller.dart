import 'package:get/get.dart';
import 'package:managerapp/main.dart';

import '../../../constants/api_constants.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';

class PrintingRulesController extends GetxController {
  final isLoading = false.obs;
  final autoPrintKitchen = true.obs;
  final kitchenNumberOfCopies = 1.obs;
  final kitchenPaperWidth = '58mm'.obs;
  final autoPrintReceiptWhenPaid = true.obs;
  final receiptNumberOfCopies = 1.obs;
  final orderPaperWidth = '58mm'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    try {
      autoPrintKitchen.value =
          box.read(ArgumentConstant.printerAutoPrintKey) ?? true;
      kitchenNumberOfCopies.value =
          box.read(ArgumentConstant.printerNumberOfCopiesKey) ?? 1;
      kitchenPaperWidth.value =
          box.read(ArgumentConstant.kitchenPaperWidthKey) ?? '58mm';
      autoPrintReceiptWhenPaid.value =
          box.read(ArgumentConstant.printerAutoPrintReceiptWhenPaidKey) ?? true;
      receiptNumberOfCopies.value =
          box.read(ArgumentConstant.printerReceiptNumberOfCopiesKey) ?? 1;
      orderPaperWidth.value =
          box.read(ArgumentConstant.orderPaperWidthKey) ?? '58mm';
    } catch (e) {}
  }

  void saveSettings({bool showToast = true}) {
    try {
      box.write(ArgumentConstant.printerAutoPrintKey, autoPrintKitchen.value);
      box.write(
        ArgumentConstant.printerNumberOfCopiesKey,
        kitchenNumberOfCopies.value,
      );
      box.write(ArgumentConstant.kitchenPaperWidthKey, kitchenPaperWidth.value);
      box.write(
        ArgumentConstant.printerAutoPrintReceiptWhenPaidKey,
        autoPrintReceiptWhenPaid.value,
      );
      box.write(
        ArgumentConstant.printerReceiptNumberOfCopiesKey,
        receiptNumberOfCopies.value,
      );
      box.write(ArgumentConstant.orderPaperWidthKey, orderPaperWidth.value);
      if (showToast) {
        AppToast.showSuccess(TranslationKeys.success.tr);
      }
    } catch (e) {}
  }

  void toggleAutoPrintKitchen() {
    autoPrintKitchen.value = !autoPrintKitchen.value;
    saveSettings(showToast: false);
  }

  void incrementKitchenCopies() {
    if (kitchenNumberOfCopies.value < 5) {
      kitchenNumberOfCopies.value++;
      saveSettings();
    }
  }

  void decrementKitchenCopies() {
    if (kitchenNumberOfCopies.value > 1) {
      kitchenNumberOfCopies.value--;
      saveSettings();
    }
  }

  void toggleAutoPrintReceiptWhenPaid() {
    autoPrintReceiptWhenPaid.value = !autoPrintReceiptWhenPaid.value;
    saveSettings(showToast: false);
  }

  void incrementReceiptCopies() {
    if (receiptNumberOfCopies.value < 5) {
      receiptNumberOfCopies.value++;
      saveSettings();
    }
  }

  void decrementReceiptCopies() {
    if (receiptNumberOfCopies.value > 1) {
      receiptNumberOfCopies.value--;
      saveSettings();
    }
  }
}
