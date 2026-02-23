import 'package:flutter/material.dart';
import '../services/escpos_invoice_printer_service.dart';
import '../utils/printer_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../constants/api_constants.dart';
import '../constants/color_constant.dart';
import '../constants/image_constants.dart';
import '../constants/sizeConstant.dart';
import 'app_toast.dart';
import '../data/NetworkClient.dart';
import '../model/tableModel.dart';
import '../model/split_payment_remaining_model.dart';
import '../model/cancelResonModel.dart' as cancelReasonModel;
import '../model/getorderModel.dart' as orderModel;
import '../routes/app_pages.dart';
import '../utils/currency_formatter.dart';
import '../utils/order_helpers.dart' as helpers;
import 'order_payment_dialog.dart';
import 'new_order_details_bottom_sheet.dart';
import '../services/sunmi_invoice_printer_service.dart';
import '../constants/translation_keys.dart';

class RunningTableService {
  static final NetworkClient networkClient = NetworkClient();

  static Map<String, dynamic>? _extractData(dynamic responseData) {
    if (responseData == null || responseData is! Map<String, dynamic>)
      return null;
    if (responseData.containsKey('data') &&
        responseData['data'] is Map<String, dynamic>) {
      return responseData['data'] as Map<String, dynamic>;
    }
    return responseData;
  }

  static String? _getOrderUuid(Tables table) => table.activeOrder?.uuid;

  static void _showError(String message) {
    AppToast.showError(message, title: 'Error');
  }

  static void _showSuccess(String message) {
    AppToast.showSuccess(message, title: 'Success');
  }

  static String _getErrorMessage(dynamic e, String defaultMessage) =>
      e is ApiException ? e.message : defaultMessage;

  static Future<Tables?> fetchTableDetails(int tableId) async {
    try {
      final response = await networkClient.get(
        ArgumentConstant.tableDetailsEndpoint.replaceAll(
          ':id',
          tableId.toString(),
        ),
      );
      if (helpers.isSuccessStatus(response.statusCode)) {
        final data = _extractData(response.data);
        if (data != null) return Tables.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<orderModel.GetOrderModel?> fetchOrderDetails(
    String orderUuid,
  ) async {
    try {
      final response = await networkClient.get(
        ArgumentConstant.getOrderEndpoint.replaceAll(':order_uuid', orderUuid),
      );
      if (!helpers.isSuccessStatus(response.statusCode) ||
          response.data is! Map<String, dynamic>) {
        return null;
      }
      return orderModel.GetOrderModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<SplitPaymentRemainingModel?> fetchRemainingSplitItems(
    String orderUuid,
  ) async {
    try {
      final response = await networkClient.get(
        ArgumentConstant.remainingSplitItemsEndpoint.replaceAll(
          ':order_uuid',
          orderUuid,
        ),
      );
      if (!helpers.isSuccessStatus(response.statusCode) ||
          response.data is! Map<String, dynamic>) {
        return null;
      }
      return SplitPaymentRemainingModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// Build [Tables] from order details (e.g. for delivery/pickup orders without a table).
  static Tables? tablesFromOrderDetails(
    orderModel.GetOrderModel? orderDetails,
  ) {
    final order = orderDetails?.data?.order;
    if (order == null) return null;
    final orderNum = int.tryParse(order.orderNumber?.toString() ?? '');
    final activeOrder = ActiveOrder(
      id: order.id,
      uuid: order.uuid,
      orderNumber: orderNum,
      status: order.status,
      total: order.totals?.total,
    );
    final orderTable = order.table;
    return Tables(
      id: orderTable?.id,
      tableCode: orderTable?.tableCode ?? order.orderType ?? 'Order',
      activeOrder: activeOrder,
    );
  }

  static Future<void> navigateToTakeOrderScreen(
    Tables table, {
    String? sourceScreen,
    bool hideTableSection = false,
  }) async {
    final orderUuid = _getOrderUuid(table);
    final order = orderUuid != null ? await fetchOrderDetails(orderUuid) : null;
    final arguments = <String, dynamic>{
      ArgumentConstant.tableKey: table,
      if (order != null) ArgumentConstant.orderKey: order,
      if (sourceScreen != null) ArgumentConstant.sourceScreenKey: sourceScreen,
      ArgumentConstant.hideTableSectionKey: hideTableSection,
    };
    Get.toNamed(Routes.TAKE_ORDER_SCREEN, arguments: arguments);
  }

  static Future<bool> _handleOrderAction(
    Tables table,
    String endpoint,
    String successMsg,
    String errorMsg,
    String noOrderMsg, {
    Map<String, dynamic>? requestBody,
    String method = 'delete',
  }) async {
    final orderUuid = _getOrderUuid(table);
    if (orderUuid == null) {
      _showError(noOrderMsg);
      return false;
    }
    try {
      final finalEndpoint = endpoint.replaceAll(':order_uuid', orderUuid);
      final response =
          method == 'delete'
              ? await networkClient.delete(finalEndpoint)
              : method == 'patch'
              ? await networkClient.patch(finalEndpoint, data: requestBody)
              : await networkClient.post(finalEndpoint, data: requestBody);
      if (helpers.isSuccessStatus(response.statusCode)) {
        _showSuccess(successMsg);
        return true;
      }
      _showError(errorMsg);
      return false;
    } catch (e) {
      _showError(_getErrorMessage(e, errorMsg));
      return false;
    }
  }

  static Future<bool> deleteOrder(Tables table) => _handleOrderAction(
    table,
    ArgumentConstant.deleteOrderEndpoint,
    'Order deleted successfully',
    'Failed to delete order',
    'No active order found to delete',
  );

  static Future<bool> changeOrderTable(Tables currentTable, int newTableId) =>
      _handleOrderAction(
        currentTable,
        ArgumentConstant.changeOrderTableEndpoint,
        'Table changed successfully',
        'Failed to change table',
        'No active order found to change table',
        requestBody: {'table_id': newTableId},
        method: 'patch',
      );

  static Future<bool> createPayment(Tables table) async {
    final orderUuid = _getOrderUuid(table);
    if (orderUuid == null) {
      _showError('No active order found to process payment');
      return false;
    }
    final orderTotal = table.activeOrder?.total ?? 0.0;
    if (orderTotal <= 0) {
      _showError('Order total is invalid');
      return false;
    }
    try {
      final response = await networkClient.post(
        ArgumentConstant.paymentsEndpoint,
        data: {
          'order_id': orderUuid,
          'amount': orderTotal.toStringAsFixed(2),
          'payment_method': 'cash',
        },
      );
      if (helpers.isSuccessStatus(response.statusCode)) {
        _showSuccess('Payment processed successfully');
        return true;
      }
      _showError('Failed to process payment');
      return false;
    } catch (e) {
      _showError(_getErrorMessage(e, 'Failed to process payment'));
      return false;
    }
  }

  static Future<List<cancelReasonModel.Data>> fetchCancelReasons() async {
    try {
      final response = await networkClient.get(
        ArgumentConstant.cancelReasonsEndpoint,
      );
      if (helpers.isSuccessStatus(response.statusCode) &&
          response.data != null) {
        final model = cancelReasonModel.CancelReasonModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (model.success == true && model.data != null) {
          return model.data!
              .where((reason) => reason.cancelOrder == true)
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<TableModel?> fetchTablesAreas() async {
    try {
      final response = await networkClient.get(
        ArgumentConstant.tablesAreasEndpoint,
      );
      if (helpers.isSuccessStatus(response.statusCode) &&
          response.data is Map<String, dynamic>) {
        return TableModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> cancelOrder(
    Tables table,
    int cancelReasonId,
    String? additionalComment,
  ) async {
    final orderUuid = _getOrderUuid(table);
    if (orderUuid == null) {
      _showError('No active order found to cancel');
      return false;
    }
    try {
      final requestBody = {
        'cancel_reason_id': cancelReasonId,
        if (additionalComment != null && additionalComment.isNotEmpty)
          'comment': additionalComment,
      };
      final response = await networkClient.post(
        ArgumentConstant.cancelOrderEndpoint.replaceAll(
          ':order_uuid',
          orderUuid,
        ),
        data: requestBody,
      );
      if (helpers.isSuccessStatus(response.statusCode)) {
        _showSuccess('Order cancelled successfully');
        return true;
      }
      _showError('Failed to cancel order');
      return false;
    } catch (e) {
      _showError(_getErrorMessage(e, 'Failed to cancel order'));
      return false;
    }
  }
}

class RunningTableDialog {
  static const _delayDuration = Duration(milliseconds: 100);
  static const _dialogPadding = EdgeInsets.all(20);
  static const _borderRadius16 = BorderRadius.all(Radius.circular(16));
  static const _borderRadius8 = BorderRadius.all(Radius.circular(8));
  static const _loadingDialog = Center(
    child: CupertinoActivityIndicator(color: Colors.white),
  );

  static Future<orderModel.GetOrderModel?> _fetchOrderDetailsWithLoader(
    String orderUuid,
  ) async {
    Get.dialog(_loadingDialog, barrierDismissible: false);
    final details = await RunningTableService.fetchOrderDetails(orderUuid);
    Get.back();
    return details;
  }

  static Widget get _buttonSpacer => SizedBox(height: MySize.getHeight(12));

  static TextStyle _textStyle(
    double fontSize, {
    FontWeight? fontWeight,
    Color? color,
  }) => TextStyle(
    fontSize: MySize.getHeight(fontSize),
    fontWeight: fontWeight,
    color: color ?? Colors.black87,
  );

  static void showRunningTablePopup({
    required BuildContext context,
    int? tableId,
    String? orderUuid,
    VoidCallback? onRefreshTables,
    Function(bool)? onSetLoader,
    String? sourceScreen,
    bool hideChangeTable = false,
  }) async {
    onSetLoader?.call(true);
    await Future.delayed(_delayDuration);

    Tables? finalTable;
    if (tableId != null) {
      final table = await RunningTableService.fetchTableDetails(tableId);
      finalTable = table ?? Tables(id: tableId);
    } else if (orderUuid != null) {
      final orderDetails = await RunningTableService.fetchOrderDetails(
        orderUuid,
      );
      finalTable = RunningTableService.tablesFromOrderDetails(orderDetails);
    }
    onSetLoader?.call(false);

    if (finalTable == null) return;

    final activeOrder = finalTable.activeOrder;
    final orderNumber = activeOrder?.orderNumber ?? 0;
    final orderTotal = CurrencyFormatter.formatPriceFromDouble(
      activeOrder?.total ?? 0.0,
    );
    final displayTableId = finalTable.id ?? tableId ?? 0;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => _buildMainDialog(
            context,
            finalTable!,
            displayTableId,
            orderNumber,
            orderTotal,
            onRefreshTables,
            onSetLoader,
            sourceScreen,
            hideChangeTable: hideChangeTable,
          ),
    );
  }

  static Widget _buildMainDialog(
    BuildContext context,
    Tables finalTable,
    int tableId,
    int orderNumber,
    String orderTotal,
    VoidCallback? onRefreshTables,
    Function(bool)? onSetLoader,
    String? sourceScreen, {
    bool hideChangeTable = false,
  }) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: _borderRadius16),
      child: Container(
        padding: _dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${finalTable.tableCode ?? finalTable.id ?? tableId} (Order #$orderNumber)',
                        style: _textStyle(16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MySize.getHeight(4)),
                      Text(
                        orderTotal,
                        style: _textStyle(18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      ImageConstant.close,
                      width: MySize.getHeight(20),
                      height: MySize.getHeight(20),
                      fit: BoxFit.contain,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MySize.getHeight(20)),
            ..._buildActionButtons(
              context,
              finalTable,
              onRefreshTables,
              onSetLoader,
              sourceScreen,
              hideChangeTable: hideChangeTable,
            ),
          ],
        ),
      ),
    );
  }

  static List<Widget> _buildActionButtons(
    BuildContext context,
    Tables finalTable,
    VoidCallback? onRefreshTables,
    Function(bool)? onSetLoader,
    String? sourceScreen, {
    bool hideChangeTable = false,
  }) {
    final buttons = <Widget>[
      _buildActionButton(
        imagePath: ImageConstant.continueOrder,
        label: 'Continue to order',
        onTap:
            () => _handleContinueToOrder(
              context,
              finalTable,
              onSetLoader,
              sourceScreen,
              hideTableSection: hideChangeTable,
            ),
      ),
      _buttonSpacer,
      _buildActionButton(
        icon: Icons.visibility_outlined,
        label: TranslationKeys.viewOrder.tr,
        onTap: () => _handleShowOrder(context, finalTable),
      ),
      _buttonSpacer,
      _buildActionButton(
        imagePath: ImageConstant.pay,
        label: 'Pay',
        onTap: () => _handlePay(context, finalTable, onRefreshTables),
      ),
      _buttonSpacer,
      _buildActionButton(
        icon: Icons.local_printshop_outlined,
        label: TranslationKeys.print.tr,
        onTap: () => _handlePrint(context, finalTable),
      ),
    ];
    if (!hideChangeTable) {
      buttons.addAll([
        _buttonSpacer,
        _buildActionButton(
          imagePath: ImageConstant.changeTable,
          label: 'Change table',
          onTap: () => _handleChangeTable(context, finalTable, onRefreshTables),
        ),
      ]);
    }
    buttons.addAll([
      _buttonSpacer,
      _buildActionButton(
        imagePath: ImageConstant.close,
        label: 'Cancel order',
        textColor: Colors.red,
        imageColor: Colors.red,
        onTap: () => _handleCancelOrder(context, finalTable, onRefreshTables),
      ),
      _buttonSpacer,
      _buildActionButton(
        imagePath: ImageConstant.delete,
        label: 'Delete order',
        textColor: Colors.red,
        imageColor: Colors.red,
        onTap: () => _handleDeleteOrder(context, finalTable, onRefreshTables),
      ),
    ]);
    return buttons;
  }

  static Future<void> _handleContinueToOrder(
    BuildContext context,
    Tables finalTable,
    Function(bool)? onSetLoader,
    String? sourceScreen, {
    bool hideTableSection = false,
  }) async {
    Navigator.of(context).pop();
    onSetLoader?.call(true);
    await Future.delayed(_delayDuration);
    await RunningTableService.navigateToTakeOrderScreen(
      finalTable,
      sourceScreen: sourceScreen,
      hideTableSection: hideTableSection,
    );
    onSetLoader?.call(false);
  }

  static Future<void> _handlePay(
    BuildContext context,
    Tables finalTable,
    VoidCallback? onRefreshTables,
  ) async {
    Get.back();
    final orderUuid = RunningTableService._getOrderUuid(finalTable);
    if (orderUuid == null) {
      RunningTableService._showError(
        'No active order found to process payment',
      );
      return;
    }
    final orderDetails = await _fetchOrderDetailsWithLoader(orderUuid);
    if (orderDetails == null) {
      RunningTableService._showError('Failed to fetch order details');
      return;
    }
    final orderType = orderDetails.data?.order?.orderType?.toLowerCase() ?? '';
    final allowSplit = orderType.contains('dine');
    final success = await OrderPaymentDialog.show(
      orderDetails: orderDetails,
      table: finalTable,
      allowSplit: allowSplit,
    );
    if (success == true) onRefreshTables?.call();
  }

  static void _handleChangeTable(
    BuildContext context,
    Tables finalTable,
    VoidCallback? onRefreshTables,
  ) {
    Navigator.of(context).pop();
    showAvailableTablesBottomSheet(
      context: context,
      currentTable: finalTable,
      tableModel: null,
      onRefreshTables: onRefreshTables,
    );
  }

  static void _handleCancelOrder(
    BuildContext context,
    Tables finalTable,
    VoidCallback? onRefreshTables,
  ) {
    Navigator.of(context).pop();
    showCancelOrderDialog(
      context: context,
      table: finalTable,
      onRefreshTables: onRefreshTables,
    );
  }

  static void _handleDeleteOrder(
    BuildContext context,
    Tables finalTable,
    VoidCallback? onRefreshTables,
  ) {
    Navigator.of(context).pop();
    showDeleteOrderConfirmationDialog(
      context: context,
      table: finalTable,
      onRefreshTables: onRefreshTables,
    );
  }

  static Future<void> _handleShowOrder(
    BuildContext context,
    Tables finalTable,
  ) async {
    final orderUuid = RunningTableService._getOrderUuid(finalTable);
    if (orderUuid == null) {
      RunningTableService._showError('No active order found to show');
      return;
    }
    final orderDetails = await _fetchOrderDetailsWithLoader(orderUuid);
    if (orderDetails?.data == null) {
      RunningTableService._showError('Failed to fetch order details');
      return;
    }
    NewOrderDetailsBottomSheet.show(orderDetails!.data!);
  }

  static Future<void> _handlePrint(
    BuildContext context,
    Tables finalTable,
  ) async {
    final orderUuid = RunningTableService._getOrderUuid(finalTable);
    if (orderUuid == null) {
      RunningTableService._showError('No active order found to print');
      return;
    }
    final orderDetails = await _fetchOrderDetailsWithLoader(orderUuid);
    if (orderDetails?.data == null) {
      RunningTableService._showError('Failed to fetch order details');
      return;
    }
    try {
      if (await PrinterHelper.isSunmiDevice()) {
        await SunmiInvoicePrinterService().printInvoice(orderDetails!.data!);
      } else {
        await EscPosInvoicePrinterService().printInvoice(orderDetails!.data!);
      }
      RunningTableService._showSuccess('Print job sent successfully');
    } catch (e) {
      RunningTableService._showError('Failed to print: $e');
    }
  }

  static void showDeleteOrderConfirmationDialog({
    required BuildContext context,
    required Tables table,
    VoidCallback? onRefreshTables,
  }) {
    final isDeletingOrder = false.obs;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: _dialogPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _borderRadius16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        ImageConstant.warning,
                        width: MySize.getHeight(24),
                        height: MySize.getHeight(24),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: MySize.getWidth(12)),
                      Expanded(
                        child: Text(
                          'Delete Order',
                          style: _textStyle(18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MySize.getHeight(16)),
                  Text(
                    'Are you sure you want to delete the order?',
                    style: _textStyle(14),
                  ),
                  SizedBox(height: MySize.getHeight(12)),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: _borderRadius8,
                      border: Border.all(color: Colors.red.shade200, width: 1),
                    ),
                    child: Text(
                      'This action cannot be undone. The order and all related data will be removed permanently.',
                      style: _textStyle(12, color: Colors.red.shade700),
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildDialogButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        isPrimary: false,
                      ),
                      SizedBox(width: MySize.getWidth(12)),
                      Obx(() {
                        final isDeleting = isDeletingOrder.value;
                        return _buildDialogButton(
                          label: 'Delete Order',
                          onPressed:
                              isDeleting
                                  ? null
                                  : () => _handleDeleteOrderAction(
                                    context,
                                    table,
                                    isDeletingOrder,
                                    onRefreshTables,
                                  ),
                          isPrimary: true,
                          isLoading: isDeleting,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static Future<void> _handleDeleteOrderAction(
    BuildContext context,
    Tables table,
    RxBool isDeletingOrder,
    VoidCallback? onRefreshTables,
  ) async {
    Navigator.of(context).pop();
    isDeletingOrder.value = true;
    final success = await RunningTableService.deleteOrder(table);
    isDeletingOrder.value = false;
    if (success) onRefreshTables?.call();
  }

  static Widget _buildDialogButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(20),
          vertical: MySize.getHeight(10),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: _borderRadius8,
          side: BorderSide(
            color: isPrimary ? Colors.red.shade300 : Colors.grey.shade300,
          ),
        ),
        backgroundColor: isPrimary ? Colors.red : Colors.white,
      ),
      child:
          isLoading
              ? SizedBox(
                width: MySize.getWidth(16),
                height: MySize.getHeight(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Text(
                label,
                style: _textStyle(
                  14,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                  color: isPrimary ? Colors.white : Colors.grey.shade700,
                ),
              ),
    );
  }

  static void showCancelOrderDialog({
    required BuildContext context,
    required Tables table,
    VoidCallback? onRefreshTables,
  }) {
    final isCancelingOrder = false.obs;
    final isFetchingCancelReasons = false.obs;
    final cancelReasons = <cancelReasonModel.Data>[].obs;
    final selectedCancelReason = ValueNotifier<cancelReasonModel.Data?>(null);
    final commentController = TextEditingController();

    _fetchCancelReasons(isFetchingCancelReasons, cancelReasons);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: _borderRadius16),
                  child: Container(
                    padding: _dialogPadding,
                    constraints: BoxConstraints(
                      maxWidth: 500,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade700,
                                size: MySize.getHeight(20),
                              ),
                              SizedBox(width: MySize.getWidth(12)),
                              Expanded(
                                child: Text(
                                  'Cancel Order',
                                  style: _textStyle(
                                    20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MySize.getHeight(12)),
                          Text(
                            'This will cancel the order and delete any associated payments. Are you sure you want to proceed?',
                            style: _textStyle(14),
                          ),
                          SizedBox(height: MySize.getHeight(16)),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: _borderRadius8,
                              border: Border.all(
                                color: Colors.orange.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange.shade700,
                                  size: MySize.getHeight(20),
                                ),
                                SizedBox(width: MySize.getWidth(8)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'This will cancel the order and delete any associated payments. Are you sure you want to proceed?',
                                        style: _textStyle(
                                          12,
                                          color: Colors.orange.shade900,
                                        ),
                                      ),
                                      SizedBox(height: MySize.getHeight(8)),
                                      Text(
                                        'Select Cancel Reason',
                                        style: _textStyle(
                                          12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MySize.getHeight(20)),
                          Text(
                            'Select Cancel Reason',
                            style: _textStyle(14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: MySize.getHeight(8)),
                          Obx(
                            () => _buildCancelReasonDropdown(
                              isFetchingCancelReasons.value,
                              cancelReasons,
                              selectedCancelReason,
                            ),
                          ),
                          SizedBox(height: MySize.getHeight(20)),
                          Text(
                            'Additional Comment (Optional)',
                            style: _textStyle(14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: MySize.getHeight(8)),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: _borderRadius8,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: commentController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Additional Comment (Optional)',
                                hintStyle: _textStyle(
                                  14,
                                  color: Colors.grey.shade600,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              style: _textStyle(14),
                            ),
                          ),
                          SizedBox(height: MySize.getHeight(24)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildDialogButton(
                                label: 'Cancel',
                                onPressed: () {
                                  selectedCancelReason.dispose();
                                  commentController.dispose();
                                  Navigator.of(context).pop();
                                },
                                isPrimary: false,
                              ),
                              SizedBox(width: MySize.getWidth(12)),
                              Obx(() {
                                final isCanceling = isCancelingOrder.value;
                                return ValueListenableBuilder<
                                  cancelReasonModel.Data?
                                >(
                                  valueListenable: selectedCancelReason,
                                  builder:
                                      (
                                        context,
                                        selectedValue,
                                        _,
                                      ) => _buildDialogButton(
                                        label: 'Cancel Order',
                                        onPressed:
                                            isCanceling || selectedValue == null
                                                ? null
                                                : () =>
                                                    _handleCancelOrderAction(
                                                      context,
                                                      table,
                                                      selectedValue,
                                                      commentController,
                                                      selectedCancelReason,
                                                      isCancelingOrder,
                                                      onRefreshTables,
                                                    ),
                                        isPrimary: true,
                                        isLoading: isCanceling,
                                      ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  static Widget _buildCancelReasonDropdown(
    bool isLoading,
    RxList<cancelReasonModel.Data> cancelReasons,
    ValueNotifier<cancelReasonModel.Data?> selectedCancelReason,
  ) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: _borderRadius8,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            SizedBox(
              width: MySize.getWidth(16),
              height: MySize.getHeight(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorConstants.primaryColor,
                ),
              ),
            ),
            SizedBox(width: MySize.getWidth(12)),
            Text(
              'Loading reasons...',
              style: _textStyle(14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _borderRadius8,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ValueListenableBuilder<cancelReasonModel.Data?>(
        valueListenable: selectedCancelReason,
        builder:
            (context, selectedValue, _) => DropdownButtonHideUnderline(
              child: DropdownButton<cancelReasonModel.Data>(
                isExpanded: true,
                value: selectedValue,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Select Cancel Reason', style: _textStyle(14)),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.arrow_drop_down, color: Colors.black87),
                ),
                items: [
                  DropdownMenuItem<cancelReasonModel.Data>(
                    value: null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Select Cancel Reason',
                        style: _textStyle(14),
                      ),
                    ),
                  ),
                  ...cancelReasons.map(
                    (reason) => DropdownMenuItem<cancelReasonModel.Data>(
                      value: reason,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(reason.reason ?? '', style: _textStyle(14)),
                      ),
                    ),
                  ),
                ],
                onChanged: (newValue) => selectedCancelReason.value = newValue,
              ),
            ),
      ),
    );
  }

  static Future<void> _handleCancelOrderAction(
    BuildContext context,
    Tables table,
    cancelReasonModel.Data selectedValue,
    TextEditingController commentController,
    ValueNotifier<cancelReasonModel.Data?> selectedCancelReason,
    RxBool isCancelingOrder,
    VoidCallback? onRefreshTables,
  ) async {
    final comment =
        commentController.text.trim().isEmpty
            ? null
            : commentController.text.trim();
    selectedCancelReason.dispose();
    commentController.dispose();
    Navigator.of(context).pop();
    isCancelingOrder.value = true;
    final success = await RunningTableService.cancelOrder(
      table,
      selectedValue.id!,
      comment,
    );
    isCancelingOrder.value = false;
    if (success) onRefreshTables?.call();
  }

  static void showAvailableTablesBottomSheet({
    required BuildContext context,
    required Tables currentTable,
    TableModel? tableModel,
    VoidCallback? onRefreshTables,
  }) {
    final isChangingTable = false.obs;
    final isLoadingTables = false.obs;
    final fetchedTableModel = Rx<TableModel?>(tableModel);

    if (tableModel == null) {
      isLoadingTables.value = true;
      RunningTableService.fetchTablesAreas()
          .then((model) {
            fetchedTableModel.value = model;
            isLoadingTables.value = false;
          })
          .catchError((e) {
            isLoadingTables.value = false;
          });
    }

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (bottomSheetContext) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            builder:
                (_, scrollController) => Builder(
                  builder:
                      (builderContext) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ColorConstants.bgColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          boxShadow: ColorConstants.getShadow2,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Available Tables',
                                    style: _textStyle(
                                      18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => Get.back(),
                                    child: Icon(
                                      Icons.close,
                                      size: MySize.getHeight(24),
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Obx(
                                () => _buildTablesList(
                                  isLoadingTables.value,
                                  fetchedTableModel.value,
                                  scrollController,
                                  currentTable,
                                  isChangingTable,
                                  onRefreshTables,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
          ),
    );
  }

  static Widget _buildTablesList(
    bool isLoading,
    TableModel? model,
    ScrollController scrollController,
    Tables currentTable,
    RxBool isChangingTable,
    VoidCallback? onRefreshTables,
  ) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(
              radius: MySize.getHeight(8),
              color: ColorConstants.primaryColor,
            ),
            SizedBox(height: MySize.getHeight(16)),
            Text(
              'Loading tables...',
              style: _textStyle(14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final tableAreas = model?.data;
    if (tableAreas == null || tableAreas.isEmpty) {
      return Center(
        child: Text(
          'No tables available',
          style: _textStyle(14, color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: tableAreas.length,
      itemBuilder: (context, areaIndex) {
        final area = tableAreas[areaIndex];
        final availableTables =
            area.tables
                ?.where(
                  (table) =>
                      table.availableStatus?.toLowerCase() == 'available' &&
                      table.status?.toLowerCase() == 'active',
                )
                .toList() ??
            [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                area.name ?? 'Unnamed Area',
                style: _textStyle(16, fontWeight: FontWeight.w600),
              ),
            ),
            if (availableTables.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'No available tables',
                  style: _textStyle(12, color: Colors.grey.shade600),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: availableTables.length,
                itemBuilder:
                    (context, tableIndex) => _buildTableItem(
                      availableTables[tableIndex],
                      currentTable,
                      isChangingTable,
                      onRefreshTables,
                    ),
              ),
            SizedBox(height: MySize.getHeight(20)),
          ],
        );
      },
    );
  }

  static Widget _buildTableItem(
    Tables table,
    Tables currentTable,
    RxBool isChangingTable,
    VoidCallback? onRefreshTables,
  ) {
    final isCurrentTable = currentTable.id == table.id;
    return Obx(() {
      final isChanging = isChangingTable.value;
      return GestureDetector(
        onTap:
            isChanging || isCurrentTable || table.id == null
                ? null
                : () => _handleTableChange(
                  table,
                  currentTable,
                  isChangingTable,
                  onRefreshTables,
                ),
        child: Opacity(
          opacity: isChanging && !isCurrentTable ? 0.5 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _borderRadius8,
              border: Border.all(
                color:
                    isCurrentTable
                        ? ColorConstants.primaryColor
                        : Colors.grey.shade300,
                width: isCurrentTable ? 2 : 1,
              ),
              boxShadow:
                  isCurrentTable
                      ? [
                        BoxShadow(
                          color: ColorConstants.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConstants.tableGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    table.tableCode ?? '${table.id}',
                    style: _textStyle(
                      12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: MySize.getHeight(4)),
                Text(
                  '${table.seatingCapacity ?? 0} Seat(s)',
                  style: _textStyle(10, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  static Future<void> _handleTableChange(
    Tables table,
    Tables currentTable,
    RxBool isChangingTable,
    VoidCallback? onRefreshTables,
  ) async {
    if (table.id == null) return;
    isChangingTable.value = true;
    final success = await RunningTableService.changeOrderTable(
      currentTable,
      table.id!,
    );
    isChangingTable.value = false;
    Get.back();
    if (success) onRefreshTables?.call();
  }

  static Future<void> _fetchCancelReasons(
    RxBool isFetchingCancelReasons,
    RxList<cancelReasonModel.Data> cancelReasons,
  ) async {
    if (isFetchingCancelReasons.value) return;
    isFetchingCancelReasons.value = true;
    try {
      cancelReasons.value = await RunningTableService.fetchCancelReasons();
    } finally {
      isFetchingCancelReasons.value = false;
    }
  }

  static Widget _buildActionButton({
    String? imagePath,
    IconData? icon,
    required String label,
    required VoidCallback? onTap,
    Color? textColor,
    Color? imageColor,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _borderRadius8,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                width: MySize.getHeight(20),
                height: MySize.getHeight(20),
                fit: BoxFit.contain,
                color: imageColor ?? Colors.black87,
              )
            else if (icon != null)
              Icon(
                icon,
                size: MySize.getHeight(20),
                color: imageColor ?? Colors.black87,
              ),
            SizedBox(width: MySize.getWidth(12)),
            Text(
              label,
              style: _textStyle(
                14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
