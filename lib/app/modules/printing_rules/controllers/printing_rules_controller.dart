import 'package:get/get.dart';
import 'package:managerapp/main.dart';

import '../../../constants/api_constants.dart';

class PrintingRulesController extends GetxController {
  final isLoading = false.obs;
  final autoPrintKitchen = true.obs;
  final kitchenNumberOfCopies = 1.obs;
  final autoPrintReceiptWhenPaid = true.obs;
  final receiptNumberOfCopies = 1.obs;

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
      autoPrintReceiptWhenPaid.value =
          box.read(ArgumentConstant.printerAutoPrintReceiptWhenPaidKey) ?? true;
      receiptNumberOfCopies.value =
          box.read(ArgumentConstant.printerReceiptNumberOfCopiesKey) ?? 1;
    } catch (e) {}
  }

  void saveSettings() {
    try {
      box.write(ArgumentConstant.printerAutoPrintKey, autoPrintKitchen.value);
      box.write(
        ArgumentConstant.printerNumberOfCopiesKey,
        kitchenNumberOfCopies.value,
      );
      box.write(
        ArgumentConstant.printerAutoPrintReceiptWhenPaidKey,
        autoPrintReceiptWhenPaid.value,
      );
      box.write(
        ArgumentConstant.printerReceiptNumberOfCopiesKey,
        receiptNumberOfCopies.value,
      );
    } catch (e) {}
  }

  void toggleAutoPrintKitchen() {
    autoPrintKitchen.value = !autoPrintKitchen.value;
    saveSettings();
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
    saveSettings();
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
