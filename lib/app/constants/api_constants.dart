class ArgumentConstant {
  static const bool isPartner = false;

  static String get baseUrl =>
      isPartner
          ? "https://partner.dinemetrics.app/"
          : "https://dev.dinemetrics.de/";

  static String get envSuffix => isPartner ? "partner" : "dev";
  static const loginEndpoint = "api/v1/pos/auth/login";
  static const restaurantUsersEndpoint =
      "api/v1/pos/restaurant/:restaurant_id/users";
  static const logoutEndpoint = "api/v1/pos/auth/logout";
  static const restaurantDetailsEndpoint =
      "api/v1/pos/restaurant/:restaurant_id/details";
  static const mobileAppModulesEndpoint =
      "api/v1/pos/user/manager-app-permissions";
  static const tokenKey = "auth_token";
  static const loginModelKey = "login_model";
  static const restaurantDetailsKey = "restaurant_details";
  static const mobileAppModulesKey = "mobile_app_modules";
  static const getOrderEndpoint = "api/v1/pos/orders/:order_uuid";
  static const deleteOrderEndpoint = "api/v1/pos/orders/:order_uuid";
  static const paymentReceiptEndpoint = "api/v1/pos/payments/:id/receipt";
  static const createRefundEndpoint =
      "api/v1/pos/orders/:order_uuid/payments/:payment_id/refunds";
  static const allOrdersEndpoint = "api/v1/pos/orders";
  static const cancelOrderEndpoint = "api/v1/pos/orders/:order_uuid/cancel";
  static const cancelReasonsEndpoint = "api/v1/pos/orders/cancel-reasons";
  static const orderKey = "order";
  static const restaurantTimezoneKey = "restaurant_timezone";
  static const savedPinKey = "saved_pin";

  // Printer Settings Keys
  static const autoPrintSettingsEndpoint =
      "api/v1/pos/branch/auto-print-settings";
  static const kitchenMonitorsEndpoint = "api/v1/pos/kitchen-monitors";
  static const kotsEndpoint = "api/v1/pos/kots";
  static const printerWidthKey = "printer_width";
  static const kitchenPaperWidthKey = "kitchen_paper_width";
  static const orderPaperWidthKey = "order_paper_width";
  static const autoPrintKitchenKey = "auto_print_kitchen";
  static const kitchenPrintCopiesKey = "kitchen_print_copies";
  static const autoPrintReceiptKey = "auto_print_receipt";
  static const receiptPrintCopiesKey = "receipt_print_copies";
  static const cachedKotChannelsKey = "cached_kot_channels";
  static const isAppForegroundKey = "is_app_foreground";

  // App Settings Keys
  static const hapticFeedbackKey = "haptic_feedback_enabled";
  static const beepSoundKey = "beep_sound_enabled";
  static const selectedLanguageKey = "selected_language";
  static const newShopOrderNotificationsKey =
      "new_shop_order_notifications_enabled";

  // Shop Settings
  static const shopSettingsEndpoint = "api/v1/pos/branch/pos-settings";
  static const shopAcceptNewOrdersKey = "accept_new_orders";
  static const shopEnableScheduleForLaterKey = "enable_schedule_for_later";
  static const shopMinOrderAmountKey = "minimum_order_amount";
  static const shopDeliveryFeeKey = "delivery_fee";
  static const shopFreeDeliveryAmountKey = "free_delivery_over_amount";
  static const shopAllowDeliveryOrdersKey = "allow_delivery_orders";
  static const shopAllowPickupOrdersKey = "allow_pickup_orders";

  // Reports
  static const dailySalesSummaryEndpoint = "api/v1/pos/reports/daily-sales-summary";
}
