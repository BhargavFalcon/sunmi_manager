import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import '../controllers/manage_printer_screen_controller.dart';

class ManagePrinterScreenView extends GetWidget<ManagePrinterScreenController> {
  const ManagePrinterScreenView({super.key});

  // ─── Reusable Styles ───────────────────────────────────────────────

  static const _cardRadius = 12.0;
  static const _pillRadius = 20.0;
  static const _buttonVerticalPadding = 16.0;

  static BoxDecoration get _bottomBarDecoration => BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.1),
        spreadRadius: 1,
        blurRadius: 10,
        offset: const Offset(0, -2),
      ),
    ],
  );

  static BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(_cardRadius),
    border: Border.all(color: Colors.grey.shade100, width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.02),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  static ButtonStyle get _outlinedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: ColorConstants.primaryColor,
    padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_cardRadius),
      side: const BorderSide(color: ColorConstants.primaryColor),
    ),
    elevation: 0,
  );

  static ButtonStyle get _filledButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: ColorConstants.primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_cardRadius),
    ),
    elevation: 0,
  );

  // ─── Reusable Widgets ──────────────────────────────────────────────

  /// Builds a status pill badge (e.g. "Default", "Set Default")
  Widget _buildStatusPill({
    required String text,
    required bool isFilled,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isFilled
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(_pillRadius),
          border: Border.all(
            color:
                isFilled
                    ? Colors.transparent
                    : Colors.blue.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Builds a centered empty state with icon, title, and subtitle
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Test Print button (shared between BT and WiFi tabs)
  Widget _buildTestPrintButton(
    BuildContext context,
    ManagePrinterScreenController controller,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: ElevatedButton.icon(
          onPressed:
              controller.isLoading.value
                  ? null
                  : () => controller.printTestReceipt(context),
          icon: const Icon(Icons.print),
          label: Text(TranslationKeys.testPrint.tr),
          style: _filledButtonStyle,
        ),
      ),
    );
  }

  /// Builds the sticky bottom action bar
  Widget _buildBottomBar({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _bottomBarDecoration,
      child: Row(children: children),
    );
  }

  /// Builds a confirmation dialog with cancel/confirm buttons
  void _showDisconnectDialog(ManagePrinterScreenController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: const BorderSide(color: ColorConstants.bgColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TranslationKeys.disconnectPrinter.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                TranslationKeys.areYouSureDisconnect.tr,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      text: TranslationKeys.cancel.tr,
                      color: Colors.grey.shade200,
                      textColor: Colors.black,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDialogButton(
                      text: TranslationKeys.disconnect.tr,
                      color: ColorConstants.primaryColor,
                      textColor: Colors.white,
                      onTap: () {
                        Get.back();
                        controller.disconnectDevice();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(text, style: TextStyle(color: textColor))),
      ),
    );
  }

  // ─── Main Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManagePrinterScreenController>(
      init: ManagePrinterScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Column(
            children: [
              _buildAppBar(context),
              Obx(
                () =>
                    controller.isSunmi.value
                        ? const SizedBox.shrink()
                        : _buildTabHeader(controller),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isSunmi.value) {
                    return _buildSunmiTab(context, controller);
                  }
                  return controller.selectedTab.value == 0
                      ? _buildBluetoothTab(context, controller)
                      : _buildWifiTab(context, controller);
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── App Bar ───────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(
            12,
          ).copyWith(top: MediaQuery.of(context).padding.top + 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: ColorConstants.getShadow2,
          ),
          child: Center(
            child: Text(
              TranslationKeys.managePrinters.tr,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: MediaQuery.of(context).padding.top + 8,
          child: InkWell(
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () => Get.back(),
            child: Container(
              alignment: Alignment.center,
              height: MySize.getHeight(30),
              width: MySize.getHeight(30),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back,
                color: ColorConstants.primaryColor,
                size: MySize.getHeight(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Tab Header ────────────────────────────────────────────────────

  Widget _buildTabHeader(ManagePrinterScreenController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildTab(controller, index: 0, label: 'Bluetooth'),
          _buildTab(controller, index: 1, label: 'WIFI'),
        ],
      ),
    );
  }

  Widget _buildTab(
    ManagePrinterScreenController controller, {
    required int index,
    required String label,
  }) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedTab.value == index;
        return InkWell(
          onTap: () => controller.selectedTab.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      isSelected
                          ? ColorConstants.primaryColor
                          : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? ColorConstants.primaryColor : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── Sunmi Tab ─────────────────────────────────────────────────────

  Widget _buildSunmiTab(
    BuildContext context,
    ManagePrinterScreenController controller,
  ) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          Expanded(
            child: _buildEmptyState(
              icon: Icons.print,
              title: controller.sunmiDeviceName.value,
              subtitle:
                  'This device has a built-in printer. No need to connect an external printer.',
            ),
          ),
          _buildBottomBar(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: () => controller.printSunmiTestReceipt(),
                    icon: const Icon(Icons.print),
                    label: const Text('Sunmi Test Print'),
                    style: _filledButtonStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Bluetooth Tab ─────────────────────────────────────────────────

  Widget _buildBluetoothTab(
    BuildContext context,
    ManagePrinterScreenController controller,
  ) {
    return Obx(() {
      if (!controller.isBluetoothEnabled.value) {
        return Container(
          width: double.infinity,
          color: const Color(0xFFF5F5F5),
          child: _buildEmptyState(
            icon: Icons.bluetooth_disabled,
            title: 'Bluetooth not enabled',
            subtitle:
                'Please turn on Bluetooth on your device to see paired devices',
          ),
        );
      }

      return Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isInitialLoading.value ||
                    (controller.isScanning.value &&
                        controller.availableDevices.isEmpty)) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CupertinoActivityIndicator(
                        radius: 16,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  );
                }

                if (controller.availableDevices.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.print_disabled,
                    title: TranslationKeys.noPrintersFound.tr,
                    subtitle: TranslationKeys.tapScanToSearch.tr,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  itemCount: controller.availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = controller.availableDevices[index];

                    return Obx(() {
                      final isConnectedDevice =
                          controller.connectedDevice.value?.macAdress ==
                          device.macAdress;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: _cardDecoration,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    device.macAdress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildBluetoothDeviceAction(
                              controller,
                              device,
                              isConnectedDevice,
                            ),
                          ],
                        ),
                      );
                    });
                  },
                );
              }),
            ),
            // ── Bottom Buttons ──
            _buildBottomBar(
              children: [
                Expanded(
                  child: Obx(() {
                    return ElevatedButton.icon(
                      onPressed:
                          controller.isScanning.value
                              ? null
                              : () => controller.scanForDevices(),
                      icon:
                          controller.isScanning.value
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(Icons.bluetooth_searching),
                      label: Text(
                        controller.isScanning.value
                            ? TranslationKeys.scanning.tr
                            : TranslationKeys.scan.tr,
                      ),
                      style: _outlinedButtonStyle,
                    );
                  }),
                ),
                Obx(() {
                  if (controller.isConnected.value &&
                      controller.connectedDevice.value != null) {
                    return _buildTestPrintButton(context, controller);
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Builds action widget for each Bluetooth device row
  Widget _buildBluetoothDeviceAction(
    ManagePrinterScreenController controller,
    dynamic device,
    bool isConnectedDevice,
  ) {
    if (isConnectedDevice) {
      return _buildStatusPill(text: 'Default', isFilled: true);
    }

    return Obx(() {
      if (controller.connectingDeviceId.value == device.macAdress) {
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: ColorConstants.primaryColor,
          ),
        );
      }
      return _buildStatusPill(
        text: 'Set Default',
        isFilled: false,
        onTap: () => controller.connectToDevice(device),
      );
    });
  }

  // ─── WiFi Tab ──────────────────────────────────────────────────────

  Widget _buildWifiTab(
    BuildContext context,
    ManagePrinterScreenController controller,
  ) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.savedWifiPrinters.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'No Saved devices',
                  subtitle: 'You have not saved any wifi devices yet.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                itemCount: controller.savedWifiPrinters.length,
                itemBuilder: (context, index) {
                  final printer = controller.savedWifiPrinters[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: _cardDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                printer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${printer.ipAddress}:${printer.port}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusPill(
                          text: printer.isDefault ? 'Default' : 'Set Default',
                          isFilled: printer.isDefault,
                          onTap:
                              () => controller.setDefaultWifiPrinter(printer),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed:
                              () => controller.deleteWifiPrinter(printer),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          // ── Bottom Buttons ──
          _buildBottomBar(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddWifiDeviceSheet(context, controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Device'),
                  style: _outlinedButtonStyle,
                ),
              ),
              Obx(() {
                if (controller.defaultWifiPrinter.value != null) {
                  return _buildTestPrintButton(context, controller);
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Add WiFi Device Sheet ─────────────────────────────────────────

  void _showAddWifiDeviceSheet(
    BuildContext context,
    ManagePrinterScreenController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                      onPressed: () => Get.back(),
                    ),
                    const Text(
                      'Enter printer details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildCupertinoInput(
                  controller: controller.deviceNameController,
                  placeholder: 'Device Name',
                ),
                const SizedBox(height: 16),
                _buildCupertinoInput(
                  controller: controller.ipAddressController,
                  placeholder: 'IP Address',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCupertinoInput(
                  controller: controller.portController,
                  placeholder: 'Port',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.wifiPaperWidth.value,
                        items:
                            ['58mm', '80mm']
                                .map(
                                  (w) => DropdownMenuItem(
                                    value: w,
                                    child: Text('Paper Width: $w'),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) controller.wifiPaperWidth.value = v;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => controller.saveWifiPrinter(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Connect Device',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Reusable Cupertino-style text input
  Widget _buildCupertinoInput({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      keyboardType: keyboardType,
    );
  }
}
