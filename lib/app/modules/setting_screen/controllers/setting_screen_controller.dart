import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../data/pusher_service.dart';
import '../../../utils/language_utils.dart';
import '../../../routes/app_pages.dart';
import '../../../model/login_models.dart';
import '../../../model/restaurant_details_model.dart';
import '../../../utils/currency_formatter.dart';
import '../../../services/app_lock_service.dart';
import '../../../services/printer_service.dart';
import '../../../model/daily_sales_summary_model.dart';
import '../../../services/network_connectivity_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../../utils/branch_utils.dart';

class SettingScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final hapticFeedbackEnabled = true.obs;
  final selectedLanguage = 'en'.obs;
  final branchName = ''.obs;
  final branchLogo = ''.obs;
  final themeHex = ''.obs;
  final kitchenTicketGenerationEnabled = true.obs;
  final isShopSettingsExpanded = false.obs;
  final appVersion = '4.0.0'.obs;
  final appBuildNumber = '12'.obs;
  final isAdmin = false.obs;

  // Shop Settings Fields
  final isShopSettingsLoading = false.obs;
  final isSavingShopSettings = false.obs;
  final isSummaryLoading = false.obs;
  final acceptNewOrders = true.obs;
  final enableScheduleForLater = true.obs;
  final allowDeliveryOrders = true.obs;
  final allowPickupOrders = true.obs;
  final minOrderAmountController = TextEditingController();
  final deliveryFeeController = TextEditingController();
  final freeDeliveryAmountController = TextEditingController();

  void toggleDeliveryOrders(bool val) {
    if (!val && !allowPickupOrders.value) {
      AppToast.showError(TranslationKeys.cannotDisableBothOrderTypes.tr);
      return;
    }
    allowDeliveryOrders.value = val;
  }

  void togglePickupOrders(bool val) {
    if (!val && !allowDeliveryOrders.value) {
      AppToast.showError(TranslationKeys.cannotDisableBothOrderTypes.tr);
      return;
    }
    allowPickupOrders.value = val;
  }

  // Currency settings
  final decimalSeparator = ".".obs;

  bool _isFetchingBranchDetails = false;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadRestaurantDetailsFromStorage();
    fetchAndRefreshBranchDetails();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.isNotEmpty) {
        appVersion.value = packageInfo.version;
      }
      if (packageInfo.buildNumber.isNotEmpty) {
        appBuildNumber.value = packageInfo.buildNumber;
      }
    } catch (e) {
      debugPrint('Error loading app version: $e');
    }
  }

  void _loadSettings() {
    hapticFeedbackEnabled.value =
        box.read(ArgumentConstant.hapticFeedbackKey) ?? true;
    selectedLanguage.value = LanguageUtils.getLanguage();
    final savedKitchenTicket =
        box.read(ArgumentConstant.kitchenTicketGenerationKey);
    kitchenTicketGenerationEnabled.value =
        savedKitchenTicket != null ? (savedKitchenTicket as bool) : true;
    decimalSeparator.value = CurrencyFormatter.getDecimalSeparator();
    isAdmin.value = BranchUtils.isCurrentUserAdmin();
    _loadAppVersion();
  }

  void _loadRestaurantDetailsFromStorage() {
    isAdmin.value = BranchUtils.isCurrentUserAdmin();
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);

      if (loginModelData != null &&
          loginModelData is Map<String, dynamic> &&
          storedData != null &&
          storedData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        final restaurantModel = RestaurantModel.fromJson(storedData);
        final branchId = loginModel.data?.user?.branchId;

        if (branchId != null) {
          final branches = restaurantModel.data?.branches;
          if (branches != null) {
            Branches? currentBranch;
            for (var b in branches) {
              if (b.id == branchId) {
                currentBranch = b;
                break;
              }
            }
            if (currentBranch != null) {
              branchName.value = currentBranch.name ?? '';
              branchLogo.value = currentBranch.logo ?? '';
              themeHex.value = currentBranch.themeHex ?? '';
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> fetchAndRefreshBranchDetails() async {
    if (_isFetchingBranchDetails) return;
    _isFetchingBranchDetails = true;
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData != null && loginModelData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        final restaurantId = loginModel.data?.user?.restaurantId;
        if (restaurantId != null) {
          final endpoint = ArgumentConstant.restaurantDetailsEndpoint
              .replaceAll(':restaurant_id', restaurantId.toString());
          final response = await networkClient.get(endpoint);
          if ((response.statusCode == 200 || response.statusCode == 201) &&
              response.data != null &&
              response.data is Map<String, dynamic>) {
            final restaurantModel = RestaurantModel.fromJson(
              response.data as Map<String, dynamic>,
            );
            box.write(
              ArgumentConstant.restaurantDetailsKey,
              restaurantModel.toJson(),
            );
            BranchUtils.saveBranchTimezone(restaurantModel);
            _loadRestaurantDetailsFromStorage();
          }
        }
      }
      await _fetchShopSettings();
    } catch (_) {
    } finally {
      _isFetchingBranchDetails = false;
    }
  }

  Future<void> _fetchShopSettings() async {
    try {
      isShopSettingsLoading.value = true;
      final response = await networkClient.get(
        ArgumentConstant.shopSettingsEndpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data != null) {
          acceptNewOrders.value =
              data[ArgumentConstant.shopAcceptNewOrdersKey] ?? true;
          enableScheduleForLater.value =
              data[ArgumentConstant.shopEnableScheduleForLaterKey] ?? true;
          allowDeliveryOrders.value =
              data[ArgumentConstant.shopAllowDeliveryOrdersKey] ?? true;
          allowPickupOrders.value =
              data[ArgumentConstant.shopAllowPickupOrdersKey] ?? true;
          minOrderAmountController.text = _formatForField(
            data[ArgumentConstant.shopMinOrderAmountKey],
          );
          deliveryFeeController.text = _formatForField(
            data[ArgumentConstant.shopDeliveryFeeKey],
          );
          freeDeliveryAmountController.text = _formatForField(
            data[ArgumentConstant.shopFreeDeliveryAmountKey],
          );
        }
      }
    } catch (_) {
      // Silently fail or show warning
    } finally {
      isShopSettingsLoading.value = false;
    }
  }

  String _formatForField(dynamic value) {
    if (value == null) return "0${decimalSeparator.value}00";
    double doubleVal = 0.0;
    if (value is String) {
      doubleVal = double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      doubleVal = value.toDouble();
    }

    String formatted = doubleVal.toStringAsFixed(
      CurrencyFormatter.getNoOfDecimals(),
    );
    if (decimalSeparator.value != ".") {
      formatted = formatted.replaceFirst(".", decimalSeparator.value);
    }
    return formatted;
  }

  double _parseFromField(String text) {
    if (text.isEmpty) return 0.0;
    String normalized = text;
    if (decimalSeparator.value != ".") {
      normalized = normalized.replaceFirst(decimalSeparator.value, ".");
    }
    normalized = normalized.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0.0;
  }

  Future<void> saveShopSettings() async {
    try {
      isSavingShopSettings.value = true;

      final data = {
        ArgumentConstant.shopAcceptNewOrdersKey: acceptNewOrders.value,
        ArgumentConstant.shopEnableScheduleForLaterKey:
            enableScheduleForLater.value,
        ArgumentConstant.shopAllowDeliveryOrdersKey: allowDeliveryOrders.value,
        ArgumentConstant.shopAllowPickupOrdersKey: allowPickupOrders.value,
        ArgumentConstant.shopMinOrderAmountKey: _parseFromField(
          minOrderAmountController.text,
        ),
        ArgumentConstant.shopDeliveryFeeKey: _parseFromField(
          deliveryFeeController.text,
        ),
        ArgumentConstant.shopFreeDeliveryAmountKey: _parseFromField(
          freeDeliveryAmountController.text,
        ),
      };

      final response = await networkClient.post(
        ArgumentConstant.shopSettingsEndpoint,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.showSuccess(TranslationKeys.success.tr);
      } else {
        AppToast.showError(TranslationKeys.error.tr);
      }
    } catch (e) {
      AppToast.showError(TranslationKeys.error.tr);
    } finally {
      isSavingShopSettings.value = false;
    }
  }

  void toggleHapticFeedback() {
    hapticFeedbackEnabled.value = !hapticFeedbackEnabled.value;
    box.write(ArgumentConstant.hapticFeedbackKey, hapticFeedbackEnabled.value);
    if (hapticFeedbackEnabled.value) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> toggleKitchenTicketGeneration() async {
    kitchenTicketGenerationEnabled.value =
        !kitchenTicketGenerationEnabled.value;
    await box.write(
      ArgumentConstant.kitchenTicketGenerationKey,
      kitchenTicketGenerationEnabled.value,
    );
    await box.save();
    _syncKotChannels(kitchenTicketGenerationEnabled.value);
    _syncBackgroundService();
  }

  void _syncKotChannels(bool enabled) {
    try {
      if (!Get.isRegistered<PusherService>()) return;
      final pusher = Get.find<PusherService>();
      if (enabled) {
        pusher.subscribeKotCreatedChannels();
      } else {
        pusher.unsubscribeKotCreatedChannels();
      }
    } catch (_) {}
  }

  void _syncBackgroundService() async {
    try {
      final bgService = FlutterBackgroundService();
      if (await bgService.isRunning()) {
        bgService.invoke('updateConfig');
      }
    } catch (_) {}
  }

  Future<void> changeLanguage(String languageCode) async {
    selectedLanguage.value = languageCode;
    box.write(ArgumentConstant.selectedLanguageKey, languageCode);
    await LanguageUtils.updateLocale(languageCode);
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await networkClient.post(ArgumentConstant.logoutEndpoint);
    } on ApiException {
      // Local logout still proceeds if the server session is already invalid.
    } catch (_) {
      // Local logout still proceeds when the API request cannot complete.
    } finally {
      isLoading.value = false;
      await _clearUserData();
    }
  }

  Future<void> _clearUserData() async {
    if (Get.isRegistered<PusherService>()) {
      await Get.find<PusherService>().disconnect();
    }
    networkClient.removeAuthToken();
    box.erase();
    
    // Hard clear of cached controllers in memory
    try {
      Get.deleteAll(force: true); // Wipes all controllers from memory to completely erase session RAM cache
      
      // Re-inject core persistent services that were just wiped
      if(!Get.isRegistered<PrinterService>()) {
        Get.put(PrinterService(), permanent: true);
      }
      if(!Get.isRegistered<NetworkConnectivityService>()) {
        Get.put(NetworkConnectivityService(), permanent: true);
      }
      if (!Get.isRegistered<AppLockService>()) {
        Get.put(AppLockService(), permanent: true);
      }
      if (!Get.isRegistered<PusherService>()) {
        Get.put(PusherService(), permanent: true);
      }
    } catch (_) {}

    Get.offAllNamed(Routes.LOGIN_SCREEN);
  }

  Future<DailySalesSummaryModel?> fetchDailySalesSummary() async {
    try {
      isSummaryLoading.value = true;
      final response = await networkClient.get(
        ArgumentConstant.dailySalesSummaryEndpoint,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return DailySalesSummaryModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } catch (e) {
      AppToast.showError(TranslationKeys.error.tr);
    } finally {
      isSummaryLoading.value = false;
    }
    return null;
  }

  @override
  void onClose() {
    minOrderAmountController.dispose();
    deliveryFeeController.dispose();
    freeDeliveryAmountController.dispose();
    super.onClose();
  }
}
