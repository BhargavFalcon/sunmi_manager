class ArgumentConstant {
  static const baseUrl = "https://dev.dinemetrics.de/";
  static const loginEndpoint = "api/v1/pos/auth/login";
  static const logoutEndpoint = "api/v1/pos/auth/logout";
  static const menuItemsEndpoint = "api/v1/pos/menu-items";
  static const restaurantDetailsEndpoint =
      "api/v1/pos/restaurant/:restaurant_id/details";
  static const tokenKey = "auth_token";
  static const loginModelKey = "login_model";
  static const menuItemsKey = "menu_items";
  static const restaurantDetailsKey = "restaurant_details";
  static const tablesAreasEndpoint = "api/v1/pos/tables/areas";
  static const tableKey = "table";
  static const ordersEndpoint = "api/v1/pos/orders/dine-in";
  static const getOrderEndpoint = "api/v1/pos/orders/:order_uuid";
  static const deleteOrderEndpoint = "api/v1/pos/orders/:order_uuid";
  static const changeOrderTableEndpoint = "api/v1/pos/orders/:order_uuid/table";
  static const addOrderItemsEndpoint =
      "api/v1/pos/orders/:order_uuid/items/sync";
  static const paymentsEndpoint = "api/v1/pos/payments";
  static const allOrdersEndpoint = "api/v1/pos/orders";
  static const orderKey = "order";

  // Printer Settings Keys
  static const printerAutoPrintKey = "printer_auto_print";
  static const printerNumberOfCopiesKey = "printer_number_of_copies";
  static const printerWidthKey = "printer_width";
  static const savedPrinterDeviceKey = "saved_printer_device";
}
