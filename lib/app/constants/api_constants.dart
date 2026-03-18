class ArgumentConstant {
  static const bool isPartner = false;

  static String get baseUrl =>
      isPartner
          ? "https://partner.dinemetrics.app/"
          : "https://dev.dinemetrics.de/";

  static String get envSuffix => isPartner ? "partner" : "dev";
  static const loginEndpoint = "api/v1/pos/auth/login";
  static const logoutEndpoint = "api/v1/pos/auth/logout";
  static const menuItemsEndpoint = "api/v1/pos/menu-items";
  static const restaurantDetailsEndpoint =
      "api/v1/pos/restaurant/:restaurant_id/details";
  static const mobileAppModulesEndpoint =
      "api/v1/pos/user/manager-app-permissions";
  static const tokenKey = "auth_token";
  static const loginModelKey = "login_model";
  static const menuItemsKey = "menu_items";
  static const restaurantDetailsKey = "restaurant_details";
  static const mobileAppModulesKey = "mobile_app_modules";
  static const tablesAreasEndpoint = "api/v1/pos/tables/areas";
  static const tableDetailsEndpoint = "api/v1/pos/tables/:id";
  static const tableKey = "table";
  static const ordersEndpoint = "api/v1/pos/orders/dine-in";
  static const deliveryOrdersEndpoint = "api/v1/pos/orders/delivery";
  static const pickupOrdersEndpoint = "api/v1/pos/orders/pickup";
  static const ordersKotEndpoint = "api/v1/pos/orders/kot";
  static const ordersBillEndpoint = "api/v1/pos/orders/bill";
  static const getOrderEndpoint = "api/v1/pos/orders/:order_uuid";
  static const deleteOrderEndpoint = "api/v1/pos/orders/:order_uuid";
  static const changeOrderTableEndpoint = "api/v1/pos/orders/:order_uuid/table";
  static const addOrderItemsEndpoint =
      "api/v1/pos/orders/:order_uuid/items/sync";
  static const paymentsEndpoint = "api/v1/pos/payments";
  static const paymentReceiptEndpoint = "api/v1/pos/payments/:id/receipt";
  static const splitPaymentEndpoint =
      "api/v1/pos/orders/:order_uuid/payments/split";
  static const remainingSplitItemsEndpoint =
      "api/v1/pos/orders/:order_uuid/remaining-split-items";
  static const allOrdersEndpoint = "api/v1/pos/orders";
  static const cancelOrderEndpoint = "api/v1/pos/orders/:order_uuid/cancel";
  static const updateOrderStatusEndpoint =
      "api/v1/pos/orders/:order_uuid/main-status";
  static const cancelReasonsEndpoint = "api/v1/pos/orders/cancel-reasons";
  static const customersEndpoint = "api/v1/pos/customers";
  static const zipcodesEndpoint = "api/v1/pos/zipcodes";
  static const reservationsEndpoint = "api/v1/pos/reservations";
  static const reservationsAvailableTimeSlotsEndpoint =
      "api/v1/pos/reservations/available-time-slots";
  static const reservationsAvailableTablesEndpoint =
      "api/v1/pos/reservations/available-tables";
  static const reservationsCheckAvailabilityEndpoint =
      "api/v1/pos/reservations/check-availability";
  static const reservationStatusEndpoint =
      "api/v1/pos/reservations/:reservation_id/status";
  static const reservationAssignTableEndpoint =
      "api/v1/pos/reservations/:reservation_id/assign-table";
  static const kotsEndpoint = "api/v1/pos/kots";
  static const updateKotStatusEndpoint = "api/v1/pos/kots/:kot_id/status";
  static const updateKotItemStatusEndpoint =
      "api/v1/pos/kots/:kot_id/items/:item_id";
  static const orderKey = "order";
  static const sourceScreenKey = "source_screen";
  static const hideTableSectionKey = "hide_table_section";
  static const deliveryCustomerIdKey = "delivery_customer_id";
  static const deliveryPreOrderDateTimeKey = "delivery_pre_order_date_time";
  static const deliveryTipAmountKey = "delivery_tip_amount";
  static const deliveryAddressKey = "delivery_address";
  static const pendingPaymentOrderIdKey = "pending_payment_order_id";
  static const restaurantTimezoneKey = "restaurant_timezone";

  // Printer Settings Keys
  static const autoPrintSettingsEndpoint =
      "api/v1/pos/branch/auto-print-settings";
  static const printerWidthKey = "printer_width";
  static const kitchenPaperWidthKey = "kitchen_paper_width";
  static const orderPaperWidthKey = "order_paper_width";
  static const savedPrinterDeviceKey = "saved_printer_device";
  static const savedWifiPrintersKey = "saved_wifi_printers";
  static const selectedKitchenPrinterKey = "selected_kitchen_printer";
  static const selectedReceiptPrinterKey = "selected_receipt_printer";

  // App Settings Keys
  static const hapticFeedbackKey = "haptic_feedback_enabled";
  static const beepSoundKey = "beep_sound_enabled";
  static const selectedLanguageKey = "selected_language";
  static const newShopOrderNotificationsKey =
      "new_shop_order_notifications_enabled";
  static const orderPlacedFromQrCodeKey = "order_placed_from_qr_code_enabled";
  static const kitchenTicketGenerationKey = "kitchen_ticket_generation_enabled";
  static const kotStatusChangeKey = "kot_status_change_enabled";
  static const newTableReservationsKey = "new_table_reservations_enabled";
  static const waiterRequestKey = "waiter_request_enabled";

  // Shop Settings
  static const shopSettingsEndpoint = "api/v1/pos/branch/pos-settings";
  static const shopAcceptNewOrdersKey = "accept_new_orders";
  static const shopEnableScheduleForLaterKey = "enable_schedule_for_later";
  static const shopMinOrderAmountKey = "minimum_order_amount";
  static const shopDeliveryFeeKey = "delivery_fee";
  static const shopFreeDeliveryAmountKey = "free_delivery_over_amount";

  // Print Service
  static const printServiceVerifyEndpoint = "api/v1/prn/verify";
  static const printServiceOldDisconnectEndpoint = "api/v1/prn/old-disconnect";

  // Print Service Keys
  static const printServiceApiKeyKey = "print_service_api_key";
  static const printServiceTokenKey = "print_service_token";
  static const isPrintServiceConnectedKey = "is_print_service_connected";
  static const printServicePrinterSettingsKey =
      "print_service_printer_settings";
  static const printServiceOpenDrawerAfterPrintKey =
      "print_service_open_drawer_after_print";
}
