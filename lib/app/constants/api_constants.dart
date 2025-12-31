class ArgumentConstant {
  static const baseUrl = "https://dev.dinemetrics.de/";
  static const loginEndpoint = "api/v1/pos/auth/login";
  static const logoutEndpoint = "api/v1/pos/auth/logout";
  static const menuItemsEndpoint = "api/v1/pos/menu-items";
  static const restaurantDetailsEndpoint =
      "api/v1/pos/restaurant/:restaurant_id/details";
  static const mobileAppModulesEndpoint =
      "api/v1/pos/restaurant/:restaurant_id/mobile-app-modules";
  static const tokenKey = "auth_token";
  static const loginModelKey = "login_model";
  static const menuItemsKey = "menu_items";
  static const restaurantDetailsKey = "restaurant_details";
  static const mobileAppModulesKey = "mobile_app_modules";
  static const tablesAreasEndpoint = "api/v1/pos/tables/areas";
  static const tableDetailsEndpoint = "api/v1/pos/tables/:id";
  static const tableKey = "table";
  static const ordersEndpoint = "api/v1/pos/orders/dine-in";
  static const getOrderEndpoint = "api/v1/pos/orders/:order_uuid";
  static const deleteOrderEndpoint = "api/v1/pos/orders/:order_uuid";
  static const changeOrderTableEndpoint = "api/v1/pos/orders/:order_uuid/table";
  static const addOrderItemsEndpoint =
      "api/v1/pos/orders/:order_uuid/items/sync";
  static const paymentsEndpoint = "api/v1/pos/payments";
  static const allOrdersEndpoint = "api/v1/pos/orders";
  static const cancelOrderEndpoint = "api/v1/pos/orders/:order_uuid/cancel";
  static const cancelReasonsEndpoint = "api/v1/pos/orders/cancel-reasons";
  static const orderKey = "order";
  static const sourceScreenKey = "source_screen";

  // Printer Settings Keys
  static const printerAutoPrintKey = "printer_auto_print";
  static const printerNumberOfCopiesKey = "printer_number_of_copies";
  static const printerWidthKey = "printer_width";
  static const savedPrinterDeviceKey = "saved_printer_device";

  // App Settings Keys
  static const hapticFeedbackKey = "haptic_feedback_enabled";
  static const beepSoundKey = "beep_sound_enabled";
  static const selectedLanguageKey = "selected_language";
  static const newShopOrderNotificationsKey = "new_shop_order_notifications_enabled";
}
